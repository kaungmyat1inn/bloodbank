import 'package:web/web.dart' as web;

/// Triggers a real browser download by synthesising an <a> element and
/// clicking it. This is more reliable than window.open for file downloads:
/// the GitHub asset URL responds with `Content-Disposition: attachment`, so
/// the browser saves the file without navigating away and without leaving a
/// blank tab behind (which window.open('_blank') does).
Future<bool> triggerBrowserDownload(String url, {String? filename}) async {
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..rel = 'noopener noreferrer';
  // Ignored for cross-origin URLs, but harmless and used as the name hint
  // when the response is same-origin.
  if (filename != null) anchor.download = filename;
  anchor.style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  return true;
}
