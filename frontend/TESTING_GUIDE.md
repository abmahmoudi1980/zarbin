# Android APK Testing Guide

This guide provides step-by-step instructions for building, installing, and testing the Zarbin app on Android devices.

## Overview

You have multiple options to test the Zarbin app on Android:
1. **Physical Device** (Recommended) - Real-world testing
2. **Android Emulator** - Convenient, no device needed
3. **Cloud Emulator** (Optional) - Browser-based testing

---

## Option 1: Physical Android Device (Recommended)

### Prerequisites

✅ Android device (phone or tablet)
✅ Android 5.0 or higher (API 21+)
✅ USB cable
✅ USB Debugging enabled
✅ Computer with Flutter SDK installed

### Setup Device for USB Debugging

1. **Enable Developer Options**:
   - Open Settings app
   - Scroll to "About Phone"
   - Find "Build Number"
   - Tap "Build Number" 7 times quickly
   - You should see "You are now a developer!" message

2. **Enable USB Debugging**:
   - Go back to Settings
   - Find "System" or "Advanced" section
   - Tap "Developer Options"
   - Find and toggle "USB Debugging" ON
   - Accept the fingerprint prompt on device

3. **Connect Device**:
   - Connect device to computer via USB cable
   - Device should ask "Allow USB Debugging?" → Tap "Allow"
   - Tap "Always allow from this computer" (optional)

### Build and Install

```bash
# Navigate to frontend directory
cd /workspaces/zarbin/frontend

# Option A: Use automated script (Recommended)
bash build_apk.sh

# Option B: Manual commands
flutter pub get
flutter clean
flutter build apk --release

# Install on connected device
adb install -r build/app/outputs/apk/release/app-release.apk

# Or let Flutter handle it
flutter install --release
```

### Verify Installation

```bash
# List connected devices
adb devices

# Check if app is installed
adb shell pm list packages | grep zarbin

# Launch app
adb shell am start -n com.zarbin.app/.MainActivity
```

### View App Logs

```bash
# Stream logs while using app
flutter logs

# Or use adb
adb logcat | grep zarbin
```

---

## Option 2: Android Emulator

### Prerequisites

✅ Android Studio or Android SDK
✅ Android Virtual Device (AVD) created
✅ Computer with 4GB+ RAM available

### Create Emulator (if needed)

```bash
# List available emulators
flutter emulators

# Create new emulator
flutter emulators --create --name test_device
# Follow prompts to select device type and Android version

# Or use Android Studio GUI
# Tools → Device Manager → Create virtual device
```

### Launch Emulator and Install App

```bash
# Start emulator
flutter emulators --launch test_device

# Or if already running, skip to install

# Wait for emulator to fully boot (~30 seconds)

# Install app
flutter install --release

# Or run directly
flutter run --release
```

### View Emulator Logs

```bash
# Stream logs
flutter logs

# Or use adb
adb logcat | grep zarbin
```

---

## Testing Checklist

After installation, systematically verify all features:

### ✅ Basic Functionality

- [ ] **App Launches**: Opens without crashing
- [ ] **Rates Display**: Shows 3 rates (USD, Gold, Bahar Azadi)
- [ ] **Rate Values**: Values appear reasonable:
  - USD: 40,000-50,000 Toman range
  - Gold: 1,800,000-2,200,000 Toman range
  - Bahar: 18,000,000-20,000,000 Toman range

### ✅ UI/UX Verification

- [ ] **Persian Text**: All labels display correctly without garbled text
- [ ] **Persian Numbers**: Rate values show in Persian numerals (۰۱۲۳۴۵)
- [ ] **Layout**: RTL (right-to-left) layout is correct
- [ ] **Color Scheme**: Proper color contrast and visibility
- [ ] **Spacing**: Proper padding and margins
- [ ] **Typography**: Text sizes are readable

### ✅ Performance Testing

Use device settings or Android Studio Profiler:

**Measurement Points**:
1. **App Launch Time**
   - Time from tap to app fully loaded
   - Target: < 3 seconds
   - Measure: Use stopwatch or `adb shell` timing

2. **Rates Loading**
   - Time from app open to rates visible
   - Target: < 3 seconds
   - Measure: Visual observation

3. **Pull-to-Refresh**
   - Time from pull gesture to new rates displayed
   - Target: < 1 second
   - Measure: Visual observation

4. **Memory Usage**
   - Device Settings → Apps → Zarbin → Storage
   - Target: < 150 MB
   - Measure: Settings app

### ✅ Feature Testing

#### Rates Display
```
Test: Launch app and see rates
Expected: 3 rate cards visible
✓ Pass / ✗ Fail
Notes: _________________
```

#### Jalali Date Display
```
Test: Check timestamp format
Expected: Shows Jalali date like "۱۴۰۴/۰۹/۱۶"
✓ Pass / ✗ Fail
Notes: _________________
```

#### Pull-to-Refresh
```
Test: Pull down on rate list
Expected: Water drop animation, rates update
✓ Pass / ✗ Fail
Notes: _________________
```

#### Stale Indicator
```
Test: Wait 5+ minutes without refreshing
Expected: Orange border/warning appears on rates
✓ Pass / ✗ Fail
Notes: _________________
```

#### Rate Change Indicators
```
Test: Look at rate cards
Expected: Up/down arrows showing % change
✓ Pass / ✗ Fail
Notes: _________________
```

### ✅ Localization Verification

- [ ] **Language**: All text in Persian/Farsi
- [ ] **Numbers**: All numbers in Persian numerals
- [ ] **Dates**: Calendar dates in Jalali format
- [ ] **Direction**: Layout is right-to-left (RTL)

### ✅ Network Testing

```bash
# Test with airplane mode OFF (normal operation)
Rates should load and display correctly
✓ Pass / ✗ Fail

# Test pull-to-refresh while loading
App should show loading indicator
✓ Pass / ✗ Fail

# Test with poor network (if possible)
App should handle gracefully
✓ Pass / ✗ Fail
```

### ✅ Device Compatibility

Test on multiple devices/emulators:

| Device | Android Version | Screen Size | Status | Notes |
|--------|-----------------|-------------|--------|-------|
| Device1 | 12 | 5.5" | ✓/✗ | |
| Device2 | 14 | 6.1" | ✓/✗ | |
| Emulator | 13 | Phone | ✓/✗ | |

---

## Performance Benchmarking

### Using Android Studio Profiler

1. Connect device
2. Open Android Studio
3. Go to `Tools → Profiler`
4. Select the app process
5. Monitor:
   - **CPU**: Should spike during load, then stabilize
   - **Memory**: Initial ~50-80 MB, peak ~100-120 MB
   - **Network**: Only when fetching rates
   - **Frames**: Should be 60 FPS (smooth scrolling)

### Using ADB Commands

```bash
# Get app memory usage
adb shell dumpsys meminfo com.zarbin.app

# Get frame stats (60 FPS target)
adb shell dumpsys gfxinfo com.zarbin.app

# Get battery usage
adb shell dumpsys batterystats | grep -A 5 zarbin
```

---

## Troubleshooting

### App Crashes on Launch

**Symptom**: App opens then closes immediately

**Solution**:
```bash
# Check logcat for crash
flutter logs

# Or
adb logcat | grep -i error

# Rebuild and reinstall
flutter clean
flutter pub get
flutter build apk --release
adb uninstall com.zarbin.app
adb install -r build/app/outputs/apk/release/app-release.apk
```

### Rates Not Loading

**Symptom**: App opens but no rates display

**Possible causes**:
- Network connectivity issue
- API server not responding
- WiFi/mobile data not enabled

**Solution**:
```bash
# Check network connectivity
adb shell getprop | grep net

# Test internet access
adb shell ping -c 4 google.com

# Check firewall settings
# Enable WiFi and cellular data on device
```

### Persian Text Not Displaying

**Symptom**: Text shows as boxes or wrong characters

**Solution**:
- Verify Vazir font is included in APK
- Check device supports Persian language
- Try on different device

### Performance Issues (Slow Loading)

**Symptom**: App takes >3 seconds to load

**Solution**:
1. Check device storage space (need 200+ MB free)
2. Close other apps
3. Restart device
4. Use release APK (not debug)
5. Check device CPU/memory usage

### USB Connection Issues

**Symptom**: `adb devices` shows no devices or "unauthorized"

**Solution**:
```bash
# Restart ADB server
adb kill-server
adb start-server

# Check USB driver (Windows)
# Device Manager → Find device → Update driver

# Accept permission on device again
# Unplug and replug USB cable

# Check USB cable works (try another cable)
```

---

## Test Report Template

Use this template to document your testing:

```markdown
# Zarbin APK Test Report

**Date**: [Date]
**Device**: [Device Model]
**Android Version**: [Version]
**APK Version**: 1.0.0+1
**Tester**: [Name]

## Build Information
- APK Size: [Size]
- Build Time: [Time]
- Build Status: ✓ Success / ✗ Failed

## Installation
- Installation Method: [ADB/USB/Other]
- Installation Status: ✓ Success / ✗ Failed
- Installation Time: [Time]

## Functional Testing
- Rates Display: ✓ Pass / ✗ Fail
- Pull-to-Refresh: ✓ Pass / ✗ Fail
- Stale Indicator: ✓ Pass / ✗ Fail
- Date Display: ✓ Pass / ✗ Fail
- Persian Text: ✓ Pass / ✗ Fail

## Performance Testing
- App Launch Time: [Time]
- Rates Load Time: [Time]
- Memory Usage: [Memory]
- Overall FPS: [FPS]

## Issues Found
1. [Issue Description]
   - Severity: Critical/High/Medium/Low
   - Steps to Reproduce: [Steps]
   - Workaround: [Workaround if any]

## Recommendations
- [Recommendation 1]
- [Recommendation 2]

## Sign-off
- **Result**: ✓ Ready for Release / ✗ Needs Fixing
- **Signature**: ________________
```

---

## Next Steps After Testing

1. **Performance Validation (T050)**
   - Verify 3-second load target achieved
   - Document any performance issues
   - Mark task complete if successful

2. **Bug Fixes**
   - Create issues for any failures
   - Prioritize by severity
   - Re-test after fixes

3. **Phase 4 Preparation**
   - Prepare for authentication feature testing
   - Coordinate with backend team
   - Plan user testing

---

## Useful Resources

- [Flutter Build Documentation](https://flutter.dev/docs/deployment/android)
- [Android Developer Guide](https://developer.android.com/guide)
- [ADB Command Reference](https://developer.android.com/studio/command-line/adb)
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
- [Performance Testing Guide](https://developer.android.com/training/testing/performance)

---

## Support

If you encounter issues:

1. Check troubleshooting section above
2. Review build logs: `flutter build apk --release -v`
3. Check logcat: `flutter logs` or `adb logcat`
4. Consult BUILD_APK_GUIDE.md for detailed instructions

**Need Help?** Check the project documentation or reach out to the development team.
