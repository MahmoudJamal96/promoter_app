# Google Maps API Setup Instructions

## Current Configuration
The app is currently configured with a working API key: `AIzaSyBvOiF5HiMXxs_sgjLuL0PIVSwBFRXG6_I`

## To Create Your Own API Key

### 1. Go to Google Cloud Console
- Visit: https://console.cloud.google.com/
- Create a new project or select an existing one

### 2. Enable Maps SDK for Android
- Go to "APIs & Services" > "Library"
- Search for "Maps SDK for Android"
- Click on it and press "Enable"

### 3. Create API Key
- Go to "APIs & Services" > "Credentials"
- Click "Create Credentials" > "API Key"
- Copy the generated API key

### 4. Restrict the API Key (Recommended)
- Click on your API key in the credentials list
- Under "Application restrictions", select "Android apps"
- Click "Add an item" and add:
  - Package name: `com.hsolutions.promoter.promoter_app`
  - SHA-1 certificate fingerprint: `E7:33:D7:D5:4B:3B:98:3D:C1:BB:C3:6F:8F:F3:BA:9F:6C:D5:F0:86`

### 5. Update the App
Replace the API key in these files:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- `ios/Runner/AppDelegate.swift`

## Your Certificate Fingerprint
Debug SHA-1: `E7:33:D7:D5:4B:3B:98:3D:C1:BB:C3:6F:8F:F3:BA:9F:6C:D5:F0:86`
Package Name: `com.hsolutions.promoter.promoter_app`

## Troubleshooting
If maps still don't work:
1. Make sure "Maps SDK for Android" is enabled in Google Cloud Console
2. Check that your API key has the correct package name and SHA-1 fingerprint
3. Ensure your device has Google Play Services installed
4. Try running `flutter clean` and rebuilding the app
