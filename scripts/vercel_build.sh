#!/usr/bin/env bash
# Vercel web build: Vercel has no Flutter toolchain, so fetch a pinned SDK
# and build. The web/ folder is committed (custom title, icons, manifest),
# so do NOT run `flutter create` here — it would overwrite those.
# Referenced from vercel.json -> buildCommand.
set -euo pipefail

FLUTTER_VERSION="3.47.2"

if [ ! -d "_flutter_sdk" ]; then
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" _flutter_sdk --depth 1
fi
export PATH="$PATH:$(pwd)/_flutter_sdk/bin"

flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release
