package com.example.grant_compass

import android.Manifest
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.CalendarContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channel = "grant_compass/device"
    private val requestCode = 4521
    private var pending: List<Map<String, Any>> = emptyList()
    private val prefs by lazy { getSharedPreferences("calendar_sync", MODE_PRIVATE) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "openUrl" -> try {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(call.arguments as String)))
                    result.success(null)
                } catch (e: Exception) { result.error("OPEN_FAILED", "No browser could open this link.", null) }
                "enableSync" -> {
                    @Suppress("UNCHECKED_CAST")
                    val items = call.arguments as? List<Map<String, Any>> ?: emptyList()
                    if (hasAccess()) {
                        prefs.edit().putBoolean("enabled", true).apply()
                        try { result.success(sync(items)) } catch (e: Exception) { result.error("CALENDAR", e.message, null) }
                    } else {
                        pending = items
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR), requestCode)
                        result.success("Allow calendar access to add reminders. Open the app again if access was denied.")
                    }
                }
                "syncIfEnabled" -> {
                    @Suppress("UNCHECKED_CAST")
                    val items = call.arguments as? List<Map<String, Any>> ?: emptyList()
                    try { if (prefs.getBoolean("enabled", false) && hasAccess()) sync(items); result.success(null) }
                    catch (e: Exception) { result.error("CALENDAR", e.message, null) }
                }
                else -> result.notImplemented()
            }
        }
    }
    private fun hasAccess() = listOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR).all {
        ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == this.requestCode && hasAccess()) {
            prefs.edit().putBoolean("enabled", true).apply()
            try { android.widget.Toast.makeText(this, sync(pending), android.widget.Toast.LENGTH_LONG).show() }
            catch (e: Exception) { android.widget.Toast.makeText(this, "Calendar update failed: ${e.message}", android.widget.Toast.LENGTH_LONG).show() }
            pending = emptyList()
        }
    }
    private fun sync(items: List<Map<String, Any>>): String {
        val resolver = contentResolver
        val activeKeys = items.mapNotNull { it["id"] as? String }.toSet()
        var removed = 0
        // Only inspect IDs recorded by this installation. Verify the event's
        // identifying content and time before deleting; users may edit events.
        for ((prefKey, value) in prefs.all) {
            if (!prefKey.startsWith("event:") || value !is Long) continue
            val key = prefKey.removePrefix("event:")
            if (key in activeKeys) continue
            val uri = android.content.ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, value)
            val event = resolver.query(uri, arrayOf(CalendarContract.Events.TITLE,
                CalendarContract.Events.DESCRIPTION, CalendarContract.Events.DTSTART), null, null, null)
            if (event == null) continue
            var missing = false
            var ownedAndPast = false
            event.use { cursor ->
                if (!cursor.moveToFirst()) missing = true
                else {
                    val title = cursor.getString(0)
                    val description = cursor.getString(1) ?: ""
                    val start = cursor.getLong(2)
                    ownedAndPast = title == key && description.contains("Check the official source:") &&
                        description.contains("This calendar time is a reminder") && start < System.currentTimeMillis()
                }
            }
            if (missing) prefs.edit().remove(prefKey).apply()
            else if (ownedAndPast && resolver.delete(uri, null, null) > 0) {
                prefs.edit().remove(prefKey).apply()
                removed++
            }
        }
        val calendars = CalendarContract.Calendars.CONTENT_URI
        val id = resolver.query(calendars, arrayOf(CalendarContract.Calendars._ID),
            "${CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL} >= ? AND ${CalendarContract.Calendars.VISIBLE} = 1",
            arrayOf(CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR.toString()), null)?.use { cursor ->
                if (cursor.moveToFirst()) cursor.getLong(0) else null
            } ?: return "No writable calendar found. Add a calendar account on your phone first."
        var added = 0
        for (item in items) {
            val key = item["id"] as? String ?: continue
            val time = (item["time"] as? Number)?.toLong() ?: continue
            if (time <= System.currentTimeMillis() || prefs.contains("event:$key")) continue
            val values = ContentValues().apply {
                put(CalendarContract.Events.CALENDAR_ID, id)
                put(CalendarContract.Events.TITLE, item["title"] as? String)
                put(CalendarContract.Events.DESCRIPTION, item["description"] as? String)
                put(CalendarContract.Events.DTSTART, time)
                put(CalendarContract.Events.DTEND, time + 3600000L)
                put(CalendarContract.Events.EVENT_TIMEZONE, java.util.TimeZone.getDefault().id)
                put(CalendarContract.Events.HAS_ALARM, 1)
            }
            val event = resolver.insert(CalendarContract.Events.CONTENT_URI, values) ?: continue
            val eventId = event.lastPathSegment?.toLongOrNull() ?: continue
            val reminder = ContentValues().apply {
                put(CalendarContract.Reminders.EVENT_ID, eventId)
                put(CalendarContract.Reminders.MINUTES, 1440)
                put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT)
            }
            try { resolver.insert(CalendarContract.Reminders.CONTENT_URI, reminder) }
            catch (e: Exception) { resolver.delete(event, null, null); throw e }
            prefs.edit().putLong("event:$key", eventId).apply()
            added++
        }
        return if (added > 0 || removed > 0) "Added $added and removed $removed expired reminder(s)." else "Calendar connected; no new or expired app reminders to update."
    }
}
