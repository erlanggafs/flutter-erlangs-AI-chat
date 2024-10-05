import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants/colors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  // Menyimpan status tampilan password
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset error message
    });

    try {
      User? user = _auth.currentUser;
      String email = user!.email!;

      // Re-authenticate user with old password
      AuthCredential credential = EmailAuthProvider.credential(
          email: email, password: _oldPasswordController.text);
      await user.reauthenticateWithCredential(credential);

      // Check if new passwords match
      if (_newPasswordController.text == _confirmPasswordController.text) {
        // Update password
        await user.updatePassword(_newPasswordController.text);
        _showDialog('Sukses',
            'Password Anda berhasil diubah. Login Kembali'); // Tampilkan dialog sukses
      } else {
        setState(() {
          _errorMessage = "Password baru tidak cocok.";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message; // Set error message
      });
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  // Menampilkan dialog
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
        title: const Text('Ubah Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPasswordField(
              controller: _oldPasswordController,
              label: 'Password Lama',
              obscureText: _obscureOldPassword,
              onToggle: () {
                setState(() {
                  _obscureOldPassword = !_obscureOldPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Password Baru',
              obscureText: _obscureNewPassword,
              onToggle: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Password Baru',
              obscureText: _obscureConfirmPassword,
              onToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary, // Ganti dengan warna yang diinginkan
                padding: const EdgeInsets.symmetric(
                    horizontal: 10), // Untuk memperbesar tombol
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Ubah Password',
                      style: TextStyle(
                          color: Colors.white), // Warna teks dalam tombol
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membangun TextField dengan tombol untuk melihat password
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onToggle, // Toggle visibility
        ),
      ),
    );
  }
}
