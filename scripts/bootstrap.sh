#!/usr/bin/env bash
# Run once after cloning (and after installing the Flutter SDK).
#
# android/ and web/ are committed to the repo (they carry the app name,
# launcher icon, favicon, browser <title>, INTERNET permission and the
# url_launcher <queries>), so there is no `flutter create` step here — it
# would overwrite those customisations.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> flutter pub get"
flutter pub get

echo ""
echo "Done. Next steps:"
echo "  1. If Firebase isn't wired yet: flutterfire configure"
echo "  2. flutter run -d chrome      # web"
echo "  3. flutter run               # connected Android device/emulator"
echo ""
echo "To regenerate launcher icons after editing assets/icon/*:"
echo "  dart run flutter_launcher_icons"
