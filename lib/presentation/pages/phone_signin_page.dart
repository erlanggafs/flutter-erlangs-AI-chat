import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import '../../constants/colors.dart'; // Halaman chat setelah login berhasil

class PhoneSignInPage extends StatefulWidget {
  const PhoneSignInPage({super.key});

  @override
  _PhoneSignInPageState createState() => _PhoneSignInPageState();
}

class _PhoneSignInPageState extends State<PhoneSignInPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isOTPRequested = false;
  bool _isLoading = false;
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Sign-In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Masukkan nomor telepon Anda'),
                ],
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixText: '+62',
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
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16.0),
            if (_isOTPRequested)
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed:
                  _isLoading ? null : (_isOTPRequested ? _verifyOTP : _sendOTP),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isOTPRequested ? 'Verifikasi OTP' : 'Kirim OTP'),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mengirim OTP
  Future<void> _sendOTP() async {
    final String phoneNumber =
        '+62${_phoneController.text.trim()}'; // Pastikan format nomor benar

    if (phoneNumber.isEmpty) {
      _showErrorDialog('Masukkan nomor telepon yang valid.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Jika verifikasi otomatis berhasil (di Android)
          await _auth.signInWithCredential(credential);
          _navigateToChatPage();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showErrorDialog('Verifikasi gagal: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isOTPRequested = true;
            _verificationId = verificationId;
          });
          _showErrorDialog('OTP telah dikirim ke nomor Anda.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showErrorDialog('Error mengirim OTP: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk verifikasi OTP
  Future<void> _verifyOTP() async {
    final String otp = _otpController.text.trim();

    if (_verificationId == null || otp.isEmpty) {
      _showErrorDialog('Masukkan OTP yang valid.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      _navigateToChatPage();
    } catch (e) {
      _showErrorDialog('Verifikasi OTP gagal: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Navigasi ke halaman chat setelah login berhasil
  void _navigateToChatPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  // Fungsi menampilkan dialog error
  void _showErrorDialog(String message) {
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
