# How to test Grant Compass on your Android phone

This guide is for the Windows computer with the project in `D:\Grants and loans`. The Android APK does not exist yet: first install the tools, prepare the project and build it. The project and calendar feature have not yet been tested, so a build or phone test may reveal issues that need fixing.

## 1. Install the tools on the computer

1. Install the Flutter SDK following https://docs.flutter.dev/install/manual. For example, extract it to `D:\flutter` and add `D:\flutter\bin` to your Windows user PATH as explained in the guide. Git is already present on this computer.
2. Install Android Studio from https://developer.android.com/studio. Open it and finish the setup wizard.
3. In Android Studio open **More Actions > SDK Manager** (or **Tools > SDK Manager**). Install the Android SDK platform and, under **SDK Tools**, Android SDK Build-Tools, Android SDK Command-line Tools and Android SDK Platform-Tools. Follow https://docs.flutter.dev/platform-integration/android/setup for the current recommended SDK components.
4. Close and reopen PowerShell so it sees the updated PATH. Run:

```powershell
flutter doctor
flutter doctor --android-licenses
```

Read the license prompts and accept them yourself if you agree. Run `flutter doctor` again and address any Android toolchain errors. Warnings for Windows desktop or other platforms do not prevent an Android build. A network connection is needed to download build components.

## 2. Prepare this project for Android

In PowerShell, enter each line and wait for it to finish:

```powershell
Set-Location -LiteralPath 'D:\Grants and loans'
flutter create --platforms=android --org com.example .
Copy-Item -LiteralPath 'android-template\MainActivity.kt' -Destination 'android\app\src\main\kotlin\com\example\grant_compass\MainActivity.kt' -Force
```

Open `android\app\src\main\AndroidManifest.xml` in a text editor. Add the two permission lines below **inside `<manifest>` and before `<application>`**; leave the existing lines in place:

```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

Save the file. Then run:

```powershell
flutter pub get
flutter analyze
flutter build apk --debug
```

If a command reports an error, stop and save or share the error message so it can be fixed. If the build succeeds, the test APK should be at `D:\Grants and loans\build\app\outputs\flutter-apk\app-debug.apk`. Do not distribute a debug build publicly.

## 3. Connect the Android phone by USB

1. Use a USB cable that supports data, unlock the phone, and connect it to the computer.
2. On the phone, open **Settings > About phone**. Find **Build number** and tap it seven times; enter your screen lock if asked. The location and wording vary by manufacturer.
3. Open **Settings > Developer options** (often under **System**) and turn on **USB debugging**.
4. If the phone asks whether to allow USB debugging from this computer, review the computer shown and choose **Allow**. Select file transfer in the USB notification if needed.
5. In PowerShell run `flutter devices`. Your Android phone should appear. If it does not, try another data cable or USB port, unlock the phone, and install the phone manufacturer's USB driver on Windows if necessary.

The official device steps are at https://docs.flutter.dev/platform-integration/android/setup.

## 4. Install and open the test app

With the phone connected and recognized, run these commands from the project folder:

```powershell
Set-Location -LiteralPath 'D:\Grants and loans'
flutter install --debug
```

If more than one device is connected, use `flutter devices` to find the Android device ID and run `flutter install --debug -d DEVICE_ID`, replacing `DEVICE_ID` with the displayed ID. Open **Grant Compass** on the phone after the install succeeds. If installing from an APK file instead of USB, Android may ask for permission for the app opening that APK; see https://support.google.com/pixelphone/answer/7391672.

## 5. Connect your calendar

1. Open the phone's calendar app and make sure a calendar account is set up and a writable calendar is visible. If using Google Calendar, check that the account and calendar are enabled and synchronized.
2. Open **Grant Compass** and tap **Connect calendar**.
3. When Android asks for calendar permission, choose **Allow**. The prototype selects the first visible writable calendar; it does not yet offer an account picker. If you have several calendars, the reminder might appear in a different calendar from the one you expect.
4. Look for the app's confirmation message. Open your calendar app and search for **EIC STEP Scale Up** on 25 November 2026 or **Baltic Marine Watchdog Challenge** on 2 December 2026, provided the relevant date is still in the future. The event's displayed time is a reminder time, not the official closing time. Confirm the current call and deadline at its official link.
5. Open an event and check whether it has alerts 30 days and 21 days before it. Alerts whose scheduled times have passed cannot fire retroactively. Calendar apps can handle alerts and sync differently; check your calendar's notification settings. If both sample dates are already past, the app will not add either event; the built-in data needs updating before this test can show a new event.

The app checks its built-in dates when opened; it does not find new grants automatically. Denying permission prevents automatic calendar insertion. To change permission later, use the phone's **Settings > Apps > Grant Compass > Permissions**, then return to the app and tap **Connect calendar** again. To stop access, revoke the permission there. Remove unwanted events in your calendar app. Reinstalling or using several devices may create duplicates.

## 6. What to tell me if something does not work

Tell me which numbered step failed, the exact error or message, your phone model and Android version. If `flutter doctor` or `flutter build apk --debug` fails, copy the relevant error text. We can then fix the build or calendar problem before relying on the app.
