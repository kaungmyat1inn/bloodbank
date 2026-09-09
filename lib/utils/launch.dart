import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [uri], showing a SnackBar on [context] if nothing can handle it.
///
/// `canLaunchUrl` returns false for `tel:` / `viber:` schemes on desktop web
/// even when the OS could handle them, so we try `launchUrl` directly and only
/// fall back to a message if that itself throws or returns false.
Future<void> launchOrNotify(
  BuildContext context,
  Uri uri, {
  String? failureMessage,
  LaunchMode mode = LaunchMode.platformDefault,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: mode);
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    messenger.showSnackBar(
      SnackBar(content: Text(failureMessage ?? 'ဖွင့်၍မရပါ - $uri')),
    );
  }
}

Future<void> callPhone(BuildContext context, String phone) {
  final trimmed = phone.trim();
  if (trimmed.isEmpty) return Future.value();
  return launchOrNotify(
    context,
    Uri(scheme: 'tel', path: trimmed),
    failureMessage: 'ဖုန်းခေါ်ဆိုမှု မဖွင့်နိုင်ပါ ($trimmed)',
  );
}

Future<void> openViber(BuildContext context, String viber) {
  final trimmed = viber.trim();
  if (trimmed.isEmpty) return Future.value();
  return launchOrNotify(
    context,
    Uri.parse('viber://chat?number=${Uri.encodeComponent(trimmed)}'),
    failureMessage: 'Viber ကို ဖွင့်၍မရပါ ($trimmed)',
  );
}
