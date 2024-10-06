import 'package:erlangs_ai/constants/colors.dart';
import 'package:erlangs_ai/presentation/controllers/change_password_controller.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final ChangePasswordController _controller = ChangePasswordController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              controller: _controller.oldPasswordController,
              label: 'Password Lama',
              obscureText: _controller.obscureOldPassword,
              onToggle: () {
                setState(() {
                  _controller.obscureOldPassword =
                      !_controller.obscureOldPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _controller.newPasswordController,
              label: 'Password Baru',
              obscureText: _controller.obscureNewPassword,
              onToggle: () {
                setState(() {
                  _controller.obscureNewPassword =
                      !_controller.obscureNewPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _controller.confirmPasswordController,
              label: 'Konfirmasi Password Baru',
              obscureText: _controller.obscureConfirmPassword,
              onToggle: () {
                setState(() {
                  _controller.obscureConfirmPassword =
                      !_controller.obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_controller.errorMessage != null)
              Text(
                _controller.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.isLoading
                  ? null
                  : () {
                      _controller.changePassword(_showDialog, setState);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: _controller.isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Ubah Password',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

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
          onPressed: onToggle,
        ),
      ),
    );
  }
}
