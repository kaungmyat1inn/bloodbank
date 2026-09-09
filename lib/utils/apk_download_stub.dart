/// Non-web fallback: there is no browser download to trigger, so callers
/// fall back to url_launcher. Returns false to signal "not handled here".
Future<bool> triggerBrowserDownload(String url, {String? filename}) async =>
    false;
