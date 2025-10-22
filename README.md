# Srikandi Sehat

" Menjadi remaja sehat dan cerdas, dalam memahami menstruasi "

Srikandi Sehat adalah aplikasi mobile yang bertujuan untuk membantu remaja perempuan dalam memahami dan mengelola kesehatan menstruasi mereka dengan cara yang sehat dan cerdas.

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

## Web Configuration
To configure the web version of the app, make sure to set up the Firebase configuration in the `web/firebase-messaging-sw.js` file and the `index.html` file located in the `web` directory.
```javascript
// web/firebase-messaging-sw.js

// Other Firebase configuration...
const firebaseConfig = {
    apiKey: "",
    authDomain: "",
    projectId: "",
    storageBucket: "",
    messagingSenderId: "",
    appId: "",
    measurementId: ""
};
// Other Firebase configuration...
```

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

## Minimal Requirements
- Flutter SDK version 3.0.0 or higher
- Dart SDK version 2.17.0 or higher
- Firebase project set up with Firestore and Authentication enabled
- Android Studio or Visual Studio Code for development
- An Android device or emulator for testing
- Xcode for iOS development (if targeting iOS)
- A valid keystore for signing the release build
- Internet connection for Firebase services
- A Google account for Firebase project setup
- Node.js and npm for web development (if targeting web)
- A code editor for editing configuration files
- Basic knowledge of Flutter and Firebase
- Git for version control
- A terminal or command prompt for running Flutter commands

## Target Platforms
- Android minimum SDK version 21. Android 5.0 (Lollipop) or higher
- iOS minimum deployment target 12.0
- Web browsers that support Firebase (latest versions of Chrome, Firefox, Safari, Edge)
- Windows 10 or higher (if targeting Windows)
- macOS 10.15 (Catalina) or higher (if targeting macOS)
- Linux distributions with GTK 3.0 or higher (if targeting Linux)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details