import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/apk_download.dart';
import '../utils/launch.dart';

/// Points at the newest GitHub Release asset — `releases/latest/download/...`
/// always resolves to the most recent published release, so a new build only
/// needs a new release, not a code change here.
const String kApkDownloadUrl =
    'https://github.com/kaungmyat1inn/bloodbank/releases/latest/download/app-release.apk';

class ApkDownloadScreen extends StatelessWidget {
  const ApkDownloadScreen({super.key});

  Future<void> _download(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    // On web this synthesises an <a> click (reliable file download). It
    // returns false on non-web, where we fall back to url_launcher.
    final handled = await triggerBrowserDownload(
      kApkDownloadUrl,
      filename: 'app-release.apk',
    );
    if (handled) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'ဒေါင်းလုတ် စတင်ပါပြီ။ browser က .apk ကို "dangerous" ဟု သတ်မှတ်လျှင် '
            'download bar တွင် "Keep" / "ဆက်လက်ဒေါင်းလုတ်" ကို နှိပ်ပါ။',
          ),
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    await launchOrNotify(
      context,
      Uri.parse(kApkDownloadUrl),
      mode: LaunchMode.externalApplication,
      failureMessage: 'ဒေါင်းလုတ် link ကို ဖွင့်၍မရပါ',
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: kApkDownloadUrl));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link ကူးယူပြီးပါပြီ — browser tab အသစ်တွင် paste လုပ်ပါ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Android App Download')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
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
                  'Android ဖုန်းများတွင် app ကို တိုက်ရိုက်ထည့်သွင်းအသုံးပြုနိုင်ရန် APK file (~55 MB) ကို ဒေါင်းလုတ်ဆွဲပါ။',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _download(context),
                  icon: const Icon(Icons.download),
                  label: const Text('APK ဒေါင်းလုတ်ဆွဲမည်'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _copyLink(context),
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('ဒေါင်းလုတ် link ကူးယူမည်'),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ဒေါင်းလုတ် မပြီးဘူးဆိုရင် —',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• Chrome/Edge က .apk ကို အန္တရာယ်ရှိနိုင်သည်ဟု ယူဆ၍ ခဏ တားထားတတ်သည်။ '
                        'ဘရောက်ဇာအောက်ခြေ download bar (သို့) Downloads (Ctrl+J) တွင် '
                        '"Keep" / "Keep anyway" ကို နှိပ်ပါ။\n'
                        '• ဖုန်း Chrome တွင် "Download anyway" ကို နှိပ်ပါ။\n'
                        '• မရသေးလျှင် အပေါ်က link ကို ကူးယူပြီး tab အသစ်တွင် ဖွင့်ပါ။',
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Install မလုပ်ခင် ဖုန်း Settings တွင် "Unknown sources / အမည်မသိ အရင်းအမြစ်" '
                  'ကို ခွင့်ပြုထားရပါမည်။',
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
