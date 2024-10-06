import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Tambahkan widget untuk login dengan nomor telepon
class PhoneSignIn extends StatefulWidget {
  @override
  _PhoneSignInState createState() => _PhoneSignInState();
}

class _PhoneSignInState extends State<PhoneSignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;

  // Kirim OTP
  void _sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Login successful!");
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  // Verifikasi OTP
  void _verifyOTP() async {
    if (_verificationId != null) {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      try {
        await _auth.signInWithCredential(credential);
        print("Successful login with OTP!");
      } catch (e) {
        print("OTP verification failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Sign-In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Nomor Telepon'),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: _sendOTP,
              child: Text('Kirim OTP'),
            ),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'Masukkan OTP'),
            ),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text('Verifikasi OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
