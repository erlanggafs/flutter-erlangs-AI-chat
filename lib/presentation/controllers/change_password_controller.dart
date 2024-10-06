import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordController {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String? errorMessage;

  // Menyimpan status tampilan password
  bool obscureOldPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  Future<void> changePassword(
      Function(String, String) showDialog, Function setState) async {
    setState(() {
      isLoading = true;
      errorMessage = null; // Reset error message
    });

    try {
      User? user = _auth.currentUser;
      String email = user!.email!;

      // Re-authenticate user with old password
      AuthCredential credential = EmailAuthProvider.credential(
          email: email, password: oldPasswordController.text);
      await user.reauthenticateWithCredential(credential);

      // Check if new passwords match
      if (newPasswordController.text == confirmPasswordController.text) {
        // Update password
        await user.updatePassword(newPasswordController.text);
        showDialog('Sukses',
            'Password Anda berhasil diubah. Login Kembali'); // Tampilkan dialog sukses
      } else {
        setState(() {
          errorMessage = "Password baru tidak cocok.";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message; // Set error message
      });
    } finally {
      setState(() {
        isLoading = false; // Reset loading state
      });
    }
  }

  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}
