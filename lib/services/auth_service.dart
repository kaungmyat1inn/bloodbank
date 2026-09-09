import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth for staff/admin login.
///
/// This app is an internal tool used by blood-bank staff to manage the donor
/// database, so it uses simple email + password accounts that an admin
/// creates for each staff member in the Firebase console (Authentication ->
/// Users -> Add user), rather than public self-service sign-up.
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
        case 'user-disabled':
          return 'ဤအကောင့်ကို ပိတ်ထားပါသည်';
        case 'too-many-requests':
          return 'ကြိုးစားမှု များလွန်းသဖြင့် ခဏစောင့်ပြီး ထပ်စမ်းကြည့်ပါ';
        case 'network-request-failed':
          return 'အင်တာနက်ချိတ်ဆက်မှု စစ်ဆေးပါ';
        default:
          return 'လော့ဂ်အင်ဝင်၍မရပါ - ${error.message ?? error.code}';
      }
    }
    return 'အမှားတစ်ခုဖြစ်ပွားပါသည်: $error';
  }
}
