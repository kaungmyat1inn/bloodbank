import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/launch.dart';

/// Update this constant after you create your first GitHub Release — see
/// the README for exactly how the CI workflow publishes the APK and what
/// URL to put here (typically:
/// https://github.com/<user>/<repo>/releases/latest/download/app-release.apk
/// which always points at the newest release automatically).
const String kApkDownloadUrl =
    'https://github.com/kaungmyat1inn/bloodbank/releases/latest/download/app-release.apk';

class ApkDownloadScreen extends StatelessWidget {
  const ApkDownloadScreen({super.key});

  bool get _isConfigured => !kApkDownloadUrl.contains('YOUR_GITHUB_USERNAME');

  Future<void> _download(BuildContext context) async {
    if (!_isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'APK link မသတ်မှတ်ရသေးပါ — lib/screens/apk_download_screen.dart ထဲ '
            'kApkDownloadUrl ကို သင့် GitHub repo နဲ့ ပြောင်းပါ',
          ),
        ),
      );
      return;
    }
    await launchOrNotify(
      context,
      Uri.parse(kApkDownloadUrl),
      mode: LaunchMode.externalApplication,
      failureMessage: 'ဒေါင်းလုတ် link ကို ဖွင့်၍မရပါ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Android App Download')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.android, size: 72, color: Color(0xFF3DDC84)),
                const SizedBox(height: 16),
                const Text(
                  'Android APK ကို ဒေါင်းလုတ်ဆွဲရန်',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Android ဖုန်းများတွင် app ကို တိုက်ရိုက်ထည့်သွင်းအသုံးပြုနိုင်ရန် APK file ကို ဒေါင်းလုတ်ဆွဲပါ။',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _download(context),
                  icon: const Icon(Icons.download),
                  label: const Text('APK ဒေါင်းလုတ်ဆွဲမည်'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Note: install မလုပ်ခင် ဖုန်းထဲက "Unknown sources" ခွင့်ပြုချက် ဖွင့်ပေးထားရပါမည်။',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
