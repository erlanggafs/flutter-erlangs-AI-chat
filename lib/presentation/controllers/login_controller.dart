import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorDialog(context, 'Please fill in all fields.');
      return;
    }

    isLoading = true;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          _showErrorDialog(context,
              'Your email has not been verified. Please check your email.');
          return;
        }
        Navigator.of(context)
            .pushReplacementNamed('/chat'); // Ganti dengan route chat
      }
    } catch (e) {
      _showErrorDialog(context, 'Login Failed: ${e.toString()}');
    } finally {
      isLoading = false;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
