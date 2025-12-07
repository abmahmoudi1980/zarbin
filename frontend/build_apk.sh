#!/bin/bash
set -e
cd "$(dirname "$0")"
flutter pub get
flutter clean
flutter build apk --release
echo "APK: build/app/outputs/apk/release/app-release.apk"
