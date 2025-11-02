# Guide for Developers

## Introduction

Welcome to the developer guide. This document provides instructions and best practices for contributing to the project.

## Prerequisites
Before you begin, ensure you have the following installed on your machine:
- Git
- Flutter SDK (for mobile development)
- Android Studio (for Android development)
- A code editor (e.g., Visual Studio Code)
- Familiarity with Dart programming language
- Familiarity with Git version control
- Basic understanding of mobile app development concepts
- Familiarity with RESTful APIs and JSON
- Familiarity with Linux command line (for advanced users)

## Setting Up Your Development Environment

### Encrypting Sensitive Information

For deployment integrations with services like GitHub Actions, it's crucial to encrypt sensitive information before adding them to your repository secrets. This includes files such as `google-services.json`, `upload-keystore.jks`, and `key.properties` required for building Android APKs via Actions.

We use base64 encoding to safely store these files as secrets. Ensure you have OpenSSL installed on your machine for encoding.

#### Steps to Encode Files

1. **Encode a file to base64:**

    - **Linux:**
      ```bash
      base64 -w 0 path/to/your/file > encoded.txt
      ```
    - **Windows (PowerShell):**
      ```powershell
      [Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\your\file")) > encoded.txt
      ```

2. **Verify file integrity after encoding:**

    - Decode the encoded file and compare it to the original to ensure they match.
      ```bash
      base64 -d encoded.txt > decoded_file
      diff path/to/your/file decoded_file
      ```
      If there is no output from `diff`, the files are identical.

3. **Copy the contents of `encoded.txt` and paste it into your GitHub repository secrets.**

4. **In your GitHub Actions workflow, i've made the step to decode the secret back to its original file:**

    ```yaml
    ...
    # 2. Steps to place secret files needed for the build
    - name: Decode and place .env file
      run: echo "${{ secrets.ENV_FILE }}" | base64 --decode > .env
      shell: bash
    ...
    ```

**Note:** Replace `${{ secrets.ENV_FILE }}` with the name of your GitHub secret (e.g., `${{ secrets.GOOGLE_SERVICES_JSON }}`, `${{ secrets.UPLOAD_KEYSTORE_JKS }}`, or `${{ secrets.KEY_PROPERTIES }}`) and `path/to/your/file` with the appropriate file path as required in your workflow. Refer to your `.github/workflows/deploy_android.yml` for the exact secret names used in your project.

This process ensures sensitive files are securely managed and accessible during automated builds.

### Android Development

Make sure your folder structure looks like this and place the necessary files in the correct locations:
```
srikandi-sehat-app/
└── android/
│  └── app/
│   │   ├── google-services.json   <-- Google Services configuration file
│   │   └── upload-keystore.jks    <-- Keystore file for signing the app
│   └── key.properties             <-- Key properties file for signing the app
└── lib/
│   └── firebase_options.dart      <-- Firebase options file
├── .env                           <-- Environment variables file
├── firebase.json                  <-- Firebase configuration file
└── pubspec.yaml
```

### Web Development

For web development, ensure you have the following files in place:
```srikandi-sehat-app/
├── lib/
│   └── firebase_options.dart      <-- Firebase options file
└── web/
│   └── firebase-messaging-sw.js   <-- Firebase messaging service worker file
├── .env                           <-- Environment variables file
├── firebase.json                  <-- Firebase configuration file
└── pubspec.yaml
```

Currently, Google login support is not available on the web. However, if you want to test the initialization, you can add the value of `GOOGLE_CLIENT_ID` in the `web/index.html` file.

**Method 1:** Add the following line inside the `<head>` tag in `web/index.html`:

```html
<meta name="google-signin-client_id" content="YOUR_GOOGLE_CLIENT_ID">
```

**Method 2:** Use the `sed` command in the terminal to replace the placeholder with your client ID value:

```bash
sed -i 's|YOUR_GOOGLE_CLIENT_ID|YOUR_CLIENT_ID_VALUE_HERE|g' web/index.html
```

## Logging

To enable detailed logging for Flutter commands, you can pipe the output through `grep` to filter for specific keywords. For example, to see all log entries related to "flutter", you can use the following command:

```bash
flutter run | grep -i "flutter"
```

## Contact Information

For any questions or assistance, please mention @ipincamp on GitHub or reach out via [email](mailto:support@nur-arifin.my.id). If you don't receive a response within 24 hours, feel free to send a follow-up message.
