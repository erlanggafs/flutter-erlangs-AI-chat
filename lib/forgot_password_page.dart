import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants/colors.dart'; // Pastikan untuk mengimpor AppColors jika diperlukan

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    final email = emailController.text;

    if (email.isEmpty) {
      // Tampilkan dialog jika email tidak diisi
      _showAlertDialog('Email tidak boleh kosong');
      return;
    }

    // Cek format email menggunakan regex
    final emailRegex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    );

    if (!emailRegex.hasMatch(email)) {
      _showAlertDialog('Format email tidak valid');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showAlertDialogWithNavigation(
          'Email reset password telah dikirim ke $email');
    } catch (e) {
      // Tangani kesalahan, misalnya email tidak terdaftar
      _showAlertDialog('Terjadi kesalahan: ${e.toString()}');
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialogWithNavigation(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pushReplacementNamed(
                    '/login'); // Navigasi ke halaman login
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Masukkan Email Anda yang terdaftar'),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(
                    color: AppColors.black,
                    width: 2.0,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Center(
                child: Text(
                  'Kirim Email Reset Password',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
