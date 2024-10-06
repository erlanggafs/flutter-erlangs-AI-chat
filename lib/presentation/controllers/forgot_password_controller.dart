import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(BuildContext context) async {
    final email = emailController.text;

    if (email.isEmpty) {
      _showAlertDialog(context, 'Email tidak boleh kosong');
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showAlertDialog(context, 'Format email tidak valid');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showAlertDialogWithNavigation(
          context, 'Email reset password telah dikirim ke $email');
    } catch (e) {
      _showAlertDialog(context, 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialogWithNavigation(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
