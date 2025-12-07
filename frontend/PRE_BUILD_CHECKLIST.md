# ✅ Android APK Build Checklist

**Purpose**: Ensure all prerequisites are met before building APK  
**Status**: Pre-build validation

---

## 📋 Pre-Build Checklist

### System Requirements

- [ ] **Flutter SDK installed**
  ```bash
  flutter --version
  # Should output: Flutter X.XX.X
  ```

- [ ] **Dart SDK installed** (comes with Flutter)
  ```bash
  dart --version
  # Should output: Dart X.XX.X
  ```

- [ ] **Android SDK installed**
  ```bash
  flutter doctor | grep Android
  # Should show: Android toolchain ✓
  ```

- [ ] **Java JDK installed** (Java 11+)
  ```bash
  java -version
  # Should output version 11+
  ```

- [ ] **ANDROID_SDK_ROOT or ANDROID_HOME set**
  ```bash
  echo $ANDROID_SDK_ROOT
  # Should show SDK path
  ```

### Android SDK Components

- [ ] **Android SDK Platform 34 (Android 14)**
  ```bash
  # Check in Android Studio:
  # Tools → SDK Manager → Platforms tab
  # Should have Android 14 (API 34) installed
  ```

- [ ] **Build Tools 34.0.0+**
  ```bash
  # Check in Android Studio:
  # Tools → SDK Manager → SDK Tools tab
  ```

- [ ] **Android Emulator** (if testing without device)
  ```bash
  flutter emulators
  # Should list available emulators
  ```

### Project Setup

- [ ] **In frontend directory**
  ```bash
  pwd
  # Should end with: /workspaces/zarbin/frontend
  ```

- [ ] **pubspec.yaml exists**
  ```bash
  ls -la pubspec.yaml
  # Should exist and be readable
  ```

- [ ] **Android directory exists**
  ```bash
  ls -la android/
  # Should show: app, gradle, build.gradle, etc.
  ```

- [ ] **Dependencies can be resolved**
  ```bash
  flutter pub get
  # Should complete without errors
  ```

---

## 🔧 Build Environment

### Pre-Build Steps

- [ ] **Clean previous builds**
  ```bash
  flutter clean
  # Remove all build artifacts
  ```

- [ ] **Get latest dependencies**
  ```bash
  flutter pub get
  # Should complete successfully
  ```

- [ ] **Verify Flutter setup**
  ```bash
  flutter doctor
  # All items should show ✓ or [!] (optional)
  ```

- [ ] **Check disk space**
  ```bash
  df -h | grep "/workspaces"
  # Should have 5+ GB available
  ```

- [ ] **Check RAM available**
  ```bash
  free -h
  # Should have 2+ GB available
  ```

---

## 📱 Device/Emulator Setup

### Physical Device

- [ ] **USB Debugging enabled**
  - Settings → About Phone → Build Number (tap 7x)
  - Settings → Developer Options → USB Debugging ✓

- [ ] **USB cable connected**
  - Using high-quality USB cable
  - Device should be recognized

- [ ] **Device detected by adb**
  ```bash
  adb devices
  # Device should list with "device" status
  ```

- [ ] **Device has 200+ MB free storage**
  - Settings → About Phone → Storage
  - Should have space for APK + app data

### Android Emulator (if using)

- [ ] **Emulator created**
  ```bash
  flutter emulators --create --name test_device
  ```

- [ ] **Emulator can launch**
  ```bash
  flutter emulators --launch test_device
  # Should open emulator window
  ```

- [ ] **Emulator fully booted**
  - Wait for home screen to appear
  - Should be responsive

---

## 🎯 Build Configuration

### Manifest Configuration

- [ ] **AndroidManifest.xml exists**
  ```bash
  ls -la android/app/src/main/AndroidManifest.xml
  ```

- [ ] **Package name correct**: `com.zarbin.app`
- [ ] **Min SDK version**: 21 (Android 5.0)
- [ ] **Target SDK version**: 34 (Android 14)
- [ ] **Permissions included**:
  - [ ] INTERNET
  - [ ] ACCESS_NETWORK_STATE
  - [ ] QUERY_ALL_PACKAGES

### Gradle Configuration

- [ ] **build.gradle exists** (project level)
  ```bash
  ls -la android/build.gradle
  ```

- [ ] **app/build.gradle exists** (app level)
  ```bash
  ls -la android/app/build.gradle
  ```

- [ ] **gradle.properties configured**
  ```bash
  cat android/gradle.properties | grep -E "useAndroidX|enableJetifier"
  # Should show: true for both
  ```

- [ ] **Gradle wrapper configured**
  ```bash
  ls -la android/gradle/wrapper/gradle-wrapper.properties
  ```

---

## 📦 Dependency Verification

### Flutter Packages

- [ ] **Provider package** (state management)
  ```bash
  grep "provider:" pubspec.yaml
  # Should be listed
  ```

- [ ] **Dio package** (HTTP client)
  ```bash
  grep "dio:" pubspec.yaml
  # Should be listed
  ```

- [ ] **Shamsi Date** (Jalali calendar)
  ```bash
  grep "shamsi_date:" pubspec.yaml
  # Should be listed
  ```

- [ ] **Pull to refresh**
  ```bash
  grep "pull_to_refresh:" pubspec.yaml
  # Should be listed
  ```

### Required Android Libraries

- [ ] **AndroidX**: Checked via gradle.properties
- [ ] **Jetifier**: Enabled via gradle.properties
- [ ] **Core Libraries**: Included in build.gradle

---

## 🔐 Security & Permissions

- [ ] **No hardcoded credentials** in code
- [ ] **No sensitive data** in manifest
- [ ] **Permissions are justified** (why they're needed)
- [ ] **User privacy** maintained (no tracking)

---

## ✅ Final Verification

- [ ] **flutter doctor shows all green**
  ```bash
  flutter doctor -v
  ```

- [ ] **No build errors when checking**
  ```bash
  flutter build apk --dry-run
  # Should complete without errors
  ```

- [ ] **Disk space adequate**
  ```bash
  df -h /workspaces
  # At least 10 GB available recommended
  ```

- [ ] **Build script is executable** (if using automated script)
  ```bash
  ls -la frontend/build_apk.sh
  # Should show -rwxr-xr-x (executable)
  ```

---

## 🚀 Ready to Build?

If all checkboxes above are checked ✅, you're ready to build:

### Option A: Automated (Recommended)
```bash
cd /workspaces/zarbin/frontend
bash build_apk.sh
```

### Option B: Manual
```bash
cd /workspaces/zarbin/frontend
flutter pub get
flutter clean
flutter build apk --release
```

---

## ⏱️ Expected Times

| Step | Time | Notes |
|------|------|-------|
| flutter pub get | 1-2 min | Downloading packages |
| flutter clean | 30 sec | Removing build artifacts |
| flutter build apk | 5-10 min | Building and optimizing |
| Total build time | ~7-12 min | First build takes longer |
| Subsequent builds | 3-5 min | Incremental builds faster |

---

## 📊 Expected Output

```
✓ Built build/app/outputs/apk/release/app-release.apk (XX.X MiB).
```

**APK Details**:
- **Location**: `build/app/outputs/apk/release/app-release.apk`
- **Size**: 60-80 MB (release build)
- **Package Name**: com.zarbin.app
- **Version**: 1.0.0+1
- **Min Android**: 5.0 (API 21)
- **Target Android**: 14 (API 34)

---

## 🐛 Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Flutter not found | Add to PATH or reinstall |
| Android SDK not found | Set ANDROID_SDK_ROOT |
| Build fails | Run `flutter clean && flutter pub get` |
| Device not recognized | Enable USB Debugging + check cable |
| Gradle sync error | Delete `.gradle` folder, rebuild |
| Out of disk space | Free up space, restart build |
| Out of memory | Close other apps, increase RAM |

For detailed troubleshooting, see `BUILD_APK_GUIDE.md`.

---

## 📝 Completion Notes

Once build completes successfully:

- [ ] **Note APK file size**: ___________ MB
- [ ] **Note build time**: ___________ minutes
- [ ] **Device used for testing**: ___________
- [ ] **Android version on device**: ___________

---

## 🎉 Next Steps

After successful build:

1. ✅ Install APK on device
   ```bash
   adb install -r build/app/outputs/apk/release/app-release.apk
   ```

2. ✅ Test functionality (see TESTING_GUIDE.md)

3. ✅ Validate performance (T050 - 3-second target)

4. ✅ Document results

5. ✅ Mark Phase 3 checkpoint complete

---

**Ready?** Go to: `APK_BUILD_SUMMARY.md` for quick start guide
