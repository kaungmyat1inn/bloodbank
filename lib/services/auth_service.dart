import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth for staff/admin accounts.
///
/// The app is an internal tool for blood-bank staff to manage the donor
/// database. Accounts are simple email + password; a new one can be created
/// from the "Register" link on the login screen (the blood-bank name is
/// stored as the account's displayName). "Forgot password" uses Firebase's
/// built-in reset-email flow — no server or SMTP setup is needed.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates a new email/password account and stores [bloodBankName] as the
  /// account's displayName. On success Firebase signs the new user in
  /// automatically, so the auth-state stream swaps the app to the home shell
  /// with no extra navigation.
  Future<void> signUp({
    required String bloodBankName,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final name = bloodBankName.trim();
    if (name.isNotEmpty) {
      await cred.user?.updateDisplayName(name);
      await cred.user?.reload();
    }
  }

  /// Sends a password-reset email via Firebase. The recipient clicks the link
  /// and sets a new password on Firebase's hosted action page.
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  /// Converts a FirebaseAuthException into a Burmese-friendly message.
  static String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'အီးမေးလ် (သို့) စကားဝှက် မှားယွင်းနေပါသည်';
        case 'invalid-email':
          return 'အီးမေးလ်ပုံစံ မှားယွင်းနေပါသည်';
        case 'missing-email':
          return 'အီးမေးလ် ထည့်ပါ';
        case 'email-already-in-use':
          return 'ဤအီးမေးလ်ဖြင့် အကောင့်ရှိပြီးသားဖြစ်သည်';
        case 'weak-password':
          return 'စကားဝှက် အားနည်းနေသည် (အနည်းဆုံး ၆ လုံး)';
        case 'operation-not-allowed':
          return 'Email/Password sign-in ကို Firebase Console တွင် ဖွင့်ထားရန် လိုအပ်သည်';
        case 'user-disabled':
          return 'ဤအကောင့်ကို ပိတ်ထားပါသည်';
        case 'too-many-requests':
          return 'ကြိုးစားမှု များလွန်းသဖြင့် ခဏစောင့်ပြီး ထပ်စမ်းကြည့်ပါ';
        case 'network-request-failed':
          return 'အင်တာနက်ချိတ်ဆက်မှု စစ်ဆေးပါ';
        default:
          return 'လုပ်ဆောင်၍မရပါ - ${error.message ?? error.code}';
      }
    }
    return 'အမှားတစ်ခုဖြစ်ပွားပါသည်: $error';
  }
}
