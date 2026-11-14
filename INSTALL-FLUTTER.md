# Install tools to build the Android APK

The download could not be completed from this session because direct network access was blocked. No SDK or APK has been installed or built yet.

1. Open the official Flutter Windows installation guide: https://docs.flutter.dev/install/manual
2. Download the current Windows stable Flutter SDK from the official guide or archive: https://docs.flutter.dev/install/archive
3. Extract it to a short folder without spaces, for example `D:\flutter` (Flutter recommends a path without spaces). The project can remain in `D:\Grants and loans`.
4. Install Android Studio from https://developer.android.com/studio and use its SDK Manager to install the Android SDK and Android SDK Command-line Tools.
5. Follow https://docs.flutter.dev/platform-integration/android/setup to configure Flutter, Android SDK components and licenses. Android Studio includes a compatible Java runtime for normal Android development.
6. After setup, follow README.md in this folder to generate and build the project. The APK will be created at `build\app\outputs\flutter-apk\app-release.apk` if the build succeeds.

These downloads are large and require free disk space and an internet connection. Do not assume the app or calendar integration works until the build and device tests have succeeded.

For a Windows computer version, also install Visual Studio with the **Desktop development with C++** workload: https://docs.flutter.dev/platform-integration/windows/setup. This is separate from Android Studio. See README.md for the Windows build command. Android phones and Android tablets use the same APK; an iPad requires a separate iOS build.
