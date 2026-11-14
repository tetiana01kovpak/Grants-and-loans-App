import Foundation
import EventKit
#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

// Add this file to each Runner target in Xcode; see README.md.
final class GrantCalendarBridge {
    private let store = EKEventStore()
    private let defaults = UserDefaults.standard
    private var channel: FlutterMethodChannel?

    func register(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "grant_compass/device", binaryMessenger: messenger)
        self.channel = channel
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { result(FlutterError(code: "UNAVAILABLE", message: "Calendar unavailable", details: nil)); return }
            switch call.method {
            case "openUrl":
                guard let text = call.arguments as? String, let url = URL(string: text), ["http", "https"].contains(url.scheme?.lowercased() ?? "") else {
                    result(FlutterError(code: "URL", message: "Invalid link", details: nil)); return
                }
                #if os(iOS)
                UIApplication.shared.open(url) { opened in
                    if opened { result(nil) } else { result(FlutterError(code: "URL", message: "Could not open the link", details: nil)) }
                }
                #elseif os(macOS)
                if NSWorkspace.shared.open(url) { result(nil) } else { result(FlutterError(code: "URL", message: "Could not open the link", details: nil)) }
                #endif
            case "enableSync":
                self.requestAccess(items: call.arguments as? [[String: Any]] ?? [], result: result)
            case "syncIfEnabled":
                guard self.defaults.bool(forKey: "grantCalendarEnabled") else { result(nil); return }
                let status = EKEventStore.authorizationStatus(for: .event)
                if #available(iOS 17.0, macOS 14.0, *) {
                    guard status == .writeOnly || status == .fullAccess else { result(nil); return }
                } else {
                    guard status == .authorized else { result(nil); return }
                }
                self.addEvents(call.arguments as? [[String: Any]] ?? [], result: result)
            default: result(FlutterMethodNotImplemented)
            }
        }
    }

    private func requestAccess(items: [[String: Any]], result: @escaping FlutterResult) {
        let completion: (Bool, Error?) -> Void = { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { result(FlutterError(code: "UNAVAILABLE", message: "Calendar unavailable", details: nil)); return }
                guard granted else { result(FlutterError(code: "PERMISSION", message: error?.localizedDescription ?? "Calendar access was not granted.", details: nil)); return }
                self.defaults.set(true, forKey: "grantCalendarEnabled")
                self.addEvents(items, result: result)
            }
        }
        if #available(iOS 17.0, macOS 14.0, *) {
            store.requestWriteOnlyAccessToEvents(completion: completion)
        } else {
            store.requestAccess(to: .event, completion: completion)
        }
    }

    private func addEvents(_ items: [[String: Any]], result: @escaping FlutterResult) {
        guard let calendar = store.defaultCalendarForNewEvents else {
            result(FlutterError(code: "NO_CALENDAR", message: "No default writable calendar is available. Set one up in Calendar first.", details: nil)); return
        }
        var added = 0
        for item in items {
            guard let id = item["id"] as? String, let milliseconds = item["time"] as? NSNumber else { continue }
            let date = Date(timeIntervalSince1970: milliseconds.doubleValue / 1000)
            let key = "grantEvent:" + id
            guard date > Date(), !defaults.bool(forKey: key) else { continue }
            let event = EKEvent(eventStore: store)
            event.calendar = calendar
            event.title = item["title"] as? String ?? "Grant reminder"
            event.notes = item["description"] as? String
            event.startDate = date
            event.endDate = date.addingTimeInterval(3600)
            event.addAlarm(EKAlarm(relativeOffset: -86400))
            do {
                try store.save(event, span: .thisEvent, commit: true)
                defaults.set(true, forKey: key)
                added += 1
            } catch {
                result(FlutterError(code: "CALENDAR", message: error.localizedDescription, details: nil)); return
            }
        }
        result(added > 0 ? "Added \(added) calendar reminder(s)." : "Calendar connected; no new future dated opportunities.")
    }
}
