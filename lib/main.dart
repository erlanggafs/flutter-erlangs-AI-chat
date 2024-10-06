import 'package:erlangs_ai/presentation/pages/change_password_page.dart';
import 'package:erlangs_ai/presentation/pages/chat_page.dart';
import 'package:erlangs_ai/core/firebase_options.dart';
import 'package:erlangs_ai/presentation/pages/forgot_password_page.dart';
import 'package:erlangs_ai/presentation/pages/login_page.dart';
import 'package:erlangs_ai/presentation/pages/splashscreen_page.dart';
import 'package:erlangs_ai/services/phone_signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat variabel lingkungan
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Erlangs AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  return const ChatPage();
                }
                return const LoginPage();
              },
            ),
        '/login': (context) => const LoginPage(),
        '/chat': (context) => const ChatPage(),
        '/phoneSignIn': (context) => PhoneSignIn(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/change-password': (context) => const ChangePasswordPage(),
      },
    );
  }
}
