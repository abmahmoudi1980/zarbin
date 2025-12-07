# APK Build Quick Start

This directory contains the Android configuration for the Zarbin Flutter app.

## Quick Build (Recommended)

### Automated Build Script
```bash
cd /workspaces/zarbin/frontend
bash build_apk.sh
```

This script will:
1. ✓ Check Flutter installation
2. ✓ Get dependencies
3. ✓ Clean build cache
4. ✓ Build release APK
5. ✓ Show APK location and size
6. ✓ Provide installation instructions

### Manual Build

```bash
cd /workspaces/zarbin/frontend

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
```

## Installation on Device

### Prerequisites
1. Enable USB Debugging:
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"
   - Connect device via USB cable

### Install APK

**Via ADB (Recommended)**
```bash
adb install -r build/app/outputs/apk/release/app-release.apk
```

**Via Flutter**
```bash
flutter install --release
```

**Via USB File Transfer**
1. Copy APK to device via USB
2. Open file manager
3. Tap APK file
4. Tap "Install"

## Testing on Emulator

```bash
# Create emulator (if needed)
flutter emulators --create --name test_device

# Launch emulator
flutter emulators --launch test_device

# Install app
flutter install --release

# Or run directly
flutter run --release
```

## Build Variants

### Debug APK (Faster, for development)
```bash
flutter build apk --debug
```
- Size: ~200-300 MB
- Build time: ~2 minutes

### Release APK (Optimized, for distribution)
```bash
flutter build apk --release
```
- Size: ~50-100 MB
- Build time: ~5 minutes
- **Recommended for testing performance**

### Split APKs (For specific architectures)
```bash
flutter build apk --target-platform android-arm64,android-arm --release
```

## Troubleshooting

### Build Fails
```bash
# Complete clean rebuild
flutter clean
flutter pub get
flutter build apk --release
```

### APK Installation Fails
```bash
# Uninstall old version first
adb uninstall com.zarbin.app

# Then install
adb install -r build/app/outputs/apk/release/app-release.apk
```

### Device Not Recognized
```bash
# List devices
adb devices

# If no devices, check USB drivers
# For Windows: https://developer.android.com/studio/run/oem-usb
# For Mac: Usually automatic
# For Linux: Check udev rules
```

## File Structure

```
android/
├── app/
│   ├── build.gradle           # App-level build config
│   ├── src/
│   │   └── main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/
│   │       │   └── MainActivity.kt
│   │       └── res/
│   │           ├── values/
│   │           │   ├── colors.xml
│   │           │   └── styles.xml
│   │           └── mipmap/
│   │               └── ic_launcher.png
│   └── release/
│       └── proguard-rules.pro
├── gradle/
│   └── wrapper/
│       └── gradle-wrapper.properties
├── build.gradle               # Project-level build config
├── gradle.properties          # Gradle configuration
├── settings.gradle            # Gradle settings
└── local.properties           # Local SDK paths (generated)
```

## App Details

- **Package Name**: com.zarbin.app
- **Min API Level**: 21 (Android 5.0)
- **Target API Level**: 34 (Android 14)
- **Permissions**:
  - INTERNET
  - ACCESS_NETWORK_STATE
  - QUERY_ALL_PACKAGES

## Performance Targets

Test these on your device:
- **App Launch**: < 3 seconds
- **Rates Load**: < 3 seconds
- **Pull-to-refresh**: < 1 second
- **Memory Usage**: < 150 MB

## Next Steps

1. Build APK using the script above
2. Install on Android device
3. Test market rates display
4. Verify Persian text rendering
5. Check pull-to-refresh functionality
6. Monitor performance metrics

---

See `BUILD_APK_GUIDE.md` for comprehensive build and testing documentation.
