#!/usr/bin/env bash
# Run this once after cloning the repo (and after installing the Flutter
# SDK) to generate the android/ and web/ platform folders. They are not
# committed to git (see .gitignore) so that they always match the exact
# Flutter SDK version each machine / CI runner has installed.
#
# Usage:  bash scripts/bootstrap.sh
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> flutter create --platforms=android,web ."
flutter create --platforms=android,web .

MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ] && ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  echo "==> Adding INTERNET permission to $MANIFEST (needed for Firebase; release builds don't get it by default)"
  sed -i.bak 's#<manifest xmlns:android="http://schemas.android.com/apk/res/android">#<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n    <uses-permission android:name="android.permission.INTERNET"/>#' "$MANIFEST"
  rm -f "$MANIFEST.bak"
fi

echo "==> flutter pub get"
flutter pub get

echo ""
echo "Done. Next steps:"
echo "  1. If you haven't yet: flutterfire configure   (connects this app to your Firebase project)"
echo "  2. flutter run -d chrome     # run the web app"
echo "  3. flutter run                # run on a connected Android device/emulator"
