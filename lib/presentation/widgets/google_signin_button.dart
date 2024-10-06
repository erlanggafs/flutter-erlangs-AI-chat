import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/chat_page.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        }
      }
    } catch (e) {
      _showErrorDialog('Google Sign-In Failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(), // Menampilkan loading indicator
          )
        : ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : _signInWithGoogle, // Fungsi ketika tombol ditekan
            icon: Image.asset(
              'assets/icons/google_logo.png',
              height: 24.0,
              width: 24.0,
            ),
            label: const Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 14.0, // Ukuran teks
                fontWeight: FontWeight.w500, // Berat huruf
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              backgroundColor: Colors.white, // Warna latar belakang tombol
              foregroundColor: Colors.black, // Warna teks dan ikon
              elevation: 2.0, // Mengatur elevasi tombol
              shape: RoundedRectangleBorder(
                // Mengatur bentuk tombol menjadi lebih kotak
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          );
  }
}
