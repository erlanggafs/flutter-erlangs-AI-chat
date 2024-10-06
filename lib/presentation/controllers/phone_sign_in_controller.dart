import 'package:erlangs_ai/presentation/pages/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneSignInController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isOTPRequested = false;
  bool isLoading = false;
  String? verificationId;

  // Fungsi untuk mengirim OTP
  Future<void> sendOTP(BuildContext context) async {
    final String phoneNumber = '+62${phoneController.text.trim()}';

    if (phoneNumber.isEmpty) {
      _showErrorDialog(context, 'Masukkan nomor telepon yang valid.');
      return;
    }

    isLoading = true;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToChatPage(context);
        },
        verificationFailed: (FirebaseAuthException e) {
          _showErrorDialog(context, 'Verifikasi gagal: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          isOTPRequested = true;
          this.verificationId = verificationId;
          _showErrorDialog(context, 'OTP telah dikirim ke nomor Anda.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      _showErrorDialog(context, 'Error mengirim OTP: $e');
    } finally {
      isLoading = false;
    }
  }

  // Fungsi untuk verifikasi OTP
  Future<void> verifyOTP(BuildContext context) async {
    final String otp = otpController.text.trim();

    if (verificationId == null || otp.isEmpty) {
      _showErrorDialog(context, 'Masukkan OTP yang valid.');
      return;
    }

    isLoading = true;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      _navigateToChatPage(context);
    } catch (e) {
      _showErrorDialog(context, 'Verifikasi OTP gagal: $e');
    } finally {
      isLoading = false;
    }
  }

  // Navigasi ke halaman chat setelah login berhasil
  void _navigateToChatPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  // Fungsi menampilkan dialog error
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
