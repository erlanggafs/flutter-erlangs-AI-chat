import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> register(BuildContext context) async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty) {
      _showErrorDialog(context, 'Please fill in all fields.');
      return;
    }

    final emailValid =
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text);
    if (!emailValid) {
      _showErrorDialog(context, 'Please enter a valid email address.');
      return;
    }

    if (passwordController.text.length < 6) {
      _showErrorDialog(context, 'Password must be at least 6 characters long.');
      return;
    }

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text,
        'email': emailController.text,
      });

      await userCredential.user!.sendEmailVerification();

      _showSuccessDialog(context,
          'Registration successful! Please verify your email before logging in.');
    } catch (e) {
      _showErrorDialog(context, 'Registration Failed: ${e.toString()}');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
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
