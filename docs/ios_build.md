# Building for iOS

This guide explains how to build and run the MacroBeast Tracker on iOS using Flutter.

## Prerequisites

- **Xcode**: Install via the Mac App Store.
- **CocoaPods**: Required for managing iOS dependencies.
  ```bash
  sudo gem install cocoapods
  ```
- **Flutter SDK**: Ensure `flutter doctor` shows no iOS issues.

## Setup

1.  **Install dependencies:**
    Navigate to the `flutter_app` directory and install packages.
    ```bash
    cd flutter_app
    flutter pub get
    ```

2.  **Install Pods:**
    Navigate to the iOS directory and install CocoaPods dependencies.
    ```bash
    cd ios
    pod install
    cd ..
    ```

## Running on Simulator

You can run the app directly from the terminal or using your IDE (Android Studio / VS Code).

**Terminal:**
```bash
# List available simulators
flutter emulators

# Launch a simulator (if not already open)
flutter emulators --launch apple_ios_simulator

# Run the app (passing the API key from .env)
flutter run --dart-define-from-file=.env
```

## Running on Physical Device

1.  **Open Workspace:**
    Open `flutter_app/ios/Runner.xcworkspace` in Xcode.
    ```bash
    open ios/Runner.xcworkspace
    ```

2.  **Signing:**
    - Select the "Runner" project in the project navigator.
    - Go to **Signing & Capabilities**.
    - Select your **Team** (you may need to add an account in Xcode > Settings > Accounts).
    - Ensure a unique **Bundle Identifier** is set if you are deploying to a real device.

3.  **Build & Run:**
    - Select your connected device in the Xcode target selector (top bar).
    - Click the **Play** button (Run).
    - *Note: The `--dart-define` values might need to be added to `Flutter/DartDefines.xcconfig` or passed manually in the Xcode scheme if `flutter run` isn't driving the build. For local development, sticking to `flutter run -d <device_id>` is recommended.*

## Building for Release (.ipa)

To create a release build for TestFlight or the App Store:

```bash
flutter build ipa --dart-define-from-file=.env --export-options-plist=ios/ExportOptions.plist
```
*(Note: You will need to generate an `ExportOptions.plist` or use Xcode's Archive manager manually).*

**Manual Archive:**
1. Open `Runner.xcworkspace` in Xcode.
2. Select **Product > Archive**.
3. Once archived, use the **Distribute App** flow to upload to App Store Connect.
