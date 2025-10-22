# Srikandi Sehat

Menjadi remaja sehat dan cerdas, dalam memahami menstruasi

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## FlutterFire Configuration
This project is configured to use [FlutterFire](https://firebase.flutter.dev/).
To add Firebase to your Flutter app, follow the instructions in the
[FlutterFire documentation](https://firebase.flutter.dev/docs/installation/ios).
Make sure to add the `google-services.json` file to the `android/app` directory
and the `GoogleService-Info.plist` file to the `ios/Runner` directory
as described in the documentation.

1. [Follow this guide](https://firebase.google.com/docs/flutter/setup?platform=android#install-cli-tools)
2. [Configure Firebase](https://firebase.google.com/docs/flutter/setup?platform=android#configure-firebase)

## Release Signing Configuration

1. This project is set up to sign the release build using a keystore.
2. To configure the signing, create a `key.properties` file in the android/ directory of the project with the following properties:
    ```sh
    storeFile=<path_to_your_keystore_file>
    storePassword=<your_keystore_password>
    keyAlias=<your_key_alias>
    keyPassword=<your_key_password>
    ```
3. Make sure to replace the placeholders with your actual keystore information. The `key.properties` file is ignored by version control to keep your keystore information secure.

### Building the App
To build the app for release, run the following command:
```sh
flutter build apk --release
```

To build the app bundle for release, run the following command:
```sh
flutter build appbundle --release
```

To build the app for ABI (e.g., arm64-v8a), run the following command:
```sh
flutter build apk --split-per-abi
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details