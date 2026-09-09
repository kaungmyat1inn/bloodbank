import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/donor_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Most commonly: firebase_options.dart still holds placeholder values.
    // Show a readable message instead of a blank white screen.
    initError = e;
  }
  runApp(BloodBankApp(initError: initError));
}

class BloodBankApp extends StatelessWidget {
  const BloodBankApp({super.key, this.initError});

  final Object? initError;

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _InitErrorScreen(error: initError!),
      );
    }

    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DonorService>(
          create: (_) => DonorService(),
          dispose: (_, service) => service.dispose(),
        ),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'သွေးလှူဒါန်းရေး',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('my'),
        supportedLocales: const [Locale('my'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const _AuthGate(),
      ),
    );
  }
}

/// Shows the login screen until a staff member is signed in, then shows the
/// main app shell. Rebuilds automatically on sign-in / sign-out because it
/// listens to the User? StreamProvider set up above.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    return user == null ? const LoginScreen() : const HomeShell();
  }
}

class _InitErrorScreen extends StatelessWidget {
  const _InitErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Color(0xFFC62828)),
                const SizedBox(height: 16),
                const Text(
                  'Firebase ချိတ်ဆက်၍မရပါ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'lib/firebase_options.dart ထဲတွင် placeholder value များ ကျန်နေပုံရသည်။\n'
                  'project root တွင် `flutterfire configure` ကို run ပြီး သင့် Firebase '
                  'project ၏ တကယ့် config values များဖြင့် အစားထိုးပါ။',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text('$error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
