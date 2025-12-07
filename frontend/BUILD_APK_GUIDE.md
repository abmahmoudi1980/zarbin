# Building APK for Android Testing

This guide explains how to build and install the Zarbin Flutter app on Android devices.

## Prerequisites

Before building an APK, ensure you have:

1. **Flutter SDK** installed (v3.16.0+)
   ```bash
   flutter doctor
   ```
   Should show ✓ for Flutter, Dart, and Android toolchain

2. **Android SDK** with:
   - SDK Platform 34 (Android 14) or higher
   - Build Tools 34.0.0 or higher
   - Android Emulator (optional, for testing without a device)

3. **Java Development Kit (JDK)** 11 or higher
   ```bash
   java -version
   ```

## Quick Start: Build Release APK

### Step 1: Navigate to Frontend Directory
```bash
cd /workspaces/zarbin/frontend
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Build APK
```bash
flutter build apk --release
```

This creates an optimized APK ready for distribution and testing.

**Location**: `build/app/outputs/apk/release/app-release.apk`

## Build Options

### Option A: Build Debug APK (Faster, Larger)
```bash
flutter build apk --debug
```
- **Use case**: Quick testing during development
- **Size**: ~200-300 MB
- **Optimization**: None
- **Location**: `build/app/outputs/apk/debug/app-debug.apk`

### Option B: Build Release APK (Recommended)
```bash
flutter build apk --release
```
- **Use case**: Distribution and performance testing
- **Size**: ~50-100 MB (optimized)
- **Optimization**: Code shrinking, obfuscation, R8 enabled
- **Location**: `build/app/outputs/apk/release/app-release.apk`

### Option C: Build App Bundle (For Google Play)
```bash
flutter build appbundle --release
```
- **Use case**: Upload to Google Play Store
- **Output**: `.aab` file (not installable on device directly)
- **Location**: `build/app/outputs/bundle/release/app-release.aab`

### Option D: Build Split APK (Multiple Architecture Support)
```bash
flutter build apk --target-platform android-arm,android-arm64 --release
```
- Creates separate APKs for different CPU architectures
- Choose based on your device:
  - `android-arm` (32-bit, older devices)
  - `android-arm64` (64-bit, modern devices)
  - `android-x86` (Intel-based emulator)
  - `android-x86_64` (Intel 64-bit emulator)

## Installation on Physical Device

### Prerequisites
- Enable USB Debugging on your Android device:
  1. Go to Settings → About Phone
  2. Tap Build Number 7 times
  3. Go to Settings → Developer Options
  4. Enable USB Debugging
  5. Connect via USB cable

### Installation

**Method 1: Direct ADB Installation**
```bash
# List connected devices
flutter devices

# Install APK on specific device
adb install -r build/app/outputs/apk/release/app-release.apk

# Or let Flutter handle it
flutter install
```

**Method 2: Transfer and Install**
1. Copy APK to device via USB
2. Open file manager on device
3. Tap the APK file
4. Tap "Install"

**Method 3: Using flutter run**
```bash
flutter run --release
```

## Installation on Emulator

### Create Android Emulator (if not exists)
```bash
flutter emulators --create --name test_device
flutter emulators --launch test_device
```

### Install on Running Emulator
```bash
flutter run --release
```

Or directly:
```bash
adb install -r build/app/outputs/apk/release/app-release.apk
```

## Testing the App

Once installed, open the app and verify:

✅ **Basic Functionality**
- [ ] App launches successfully
- [ ] Market rates display (USD, Gold, Bahar Azadi)
- [ ] Rates shown in Persian numerals
- [ ] Jalali date displays correctly
- [ ] Pull-to-refresh works
- [ ] Stale indicator appears after 5 minutes

✅ **Visual Elements**
- [ ] Persian text displays correctly (no garbled characters)
- [ ] Layout is right-to-left (RTL)
- [ ] Colors and spacing look good
- [ ] Buttons are clickable

✅ **Performance**
- [ ] App opens within 3 seconds
- [ ] Rates load within 3 seconds
- [ ] No lag during scrolling
- [ ] No memory issues (check in Settings → App Info → Storage)

## Troubleshooting

### APK Build Fails

**Error**: "No Android SDK found"
```bash
flutter config --android-sdk /path/to/android/sdk
```

**Error**: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

**Error**: "Failed to extract android-31"
```bash
rm -rf ~/.gradle
flutter clean
flutter pub get
flutter build apk --release
```

### App Crashes on Launch

1. Check logs:
```bash
flutter logs
```

2. Rebuild from scratch:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

3. Check for API level compatibility:
```bash
# App requires Android API 21+
# Verify your device/emulator is Android 5.0 or higher
```

### Permission Issues

Add required permissions in `android/app/src/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Large APK Size

To reduce size:
```bash
flutter build apk --release --split-per-abi
```

This creates separate APKs for each CPU architecture (arm, arm64, x86, x86_64).

## Performance Monitoring

### On Device
1. Connect to Android Studio
2. Use Android Profiler to monitor:
   - CPU usage
   - Memory usage
   - Network activity
   - Jank frames

### Via Command Line
```bash
# Enable verbose logging
flutter run -v

# Monitor frame rendering
flutter run -vvv
```

## Signing APK for Distribution

For production releases, sign the APK:

```bash
# Generate keystore (one-time)
keytool -genkey -v -keystore ~/zarbin.jks -keyalg RSA -keysize 2048 -validity 10000 -alias zarbin

# Sign APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/zarbin.jks build/app/outputs/apk/release/app-release-unsigned.apk zarbin

# Verify alignment (optional)
zipalign -v 4 build/app/outputs/apk/release/app-release.apk build/app/outputs/apk/release/app-release-signed.apk
```

## Next Steps

### Performance Validation (T050)
After building and installing, measure:
- Initial load time (target: <3 seconds)
- Pull-to-refresh response time
- Memory usage under load

### Further Testing
- Test on multiple Android versions (API 21-34)
- Test on different device sizes (phone, tablet)
- Test offline functionality
- Test with poor network connectivity

## Useful Commands

```bash
# Check Flutter setup
flutter doctor -v

# List available devices
flutter devices

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run app in debug mode
flutter run

# Run app in release mode
flutter run --release

# View logs
flutter logs

# View app on device
flutter attach

# Uninstall app
flutter uninstall

# Check APK info
aapt dump badging build/app/outputs/apk/release/app-release.apk

# Get APK file size
ls -lh build/app/outputs/apk/release/app-release.apk
```

## References

- [Flutter Build APK Documentation](https://flutter.dev/docs/deployment/android)
- [Android Developer Guide](https://developer.android.com/)
- [Gradle Build System](https://gradle.org/)
- [Android SDK Platform Releases](https://developer.android.com/studio/releases/platforms)

---

**Note**: The app requires Android 5.0 (API 21) or higher and Internet connectivity to fetch market rates from the TGJU API.
