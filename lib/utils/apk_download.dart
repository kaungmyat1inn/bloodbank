// Cross-platform entry point for kicking off the APK download.
//
// On web this resolves to a real <a download> click (see apk_download_web.dart);
// everywhere else it is a no-op returning false so callers fall back to
// url_launcher.
export 'apk_download_stub.dart'
    if (dart.library.js_interop) 'apk_download_web.dart';
