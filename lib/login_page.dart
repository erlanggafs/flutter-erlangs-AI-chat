import 'package:erlangs_ai/chat_page.dart';
import 'package:erlangs_ai/register_page.dart';
import 'package:erlangs_ai/phone_signin_page.dart'; // Tambahkan import ini
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'constants/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, right: 15, left: 15),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const Icon(
              Icons.model_training,
              color: AppColors.primary,
              size: 120,
            ),
            const Text(
              'Erlangs AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email,
                    color: AppColors.black,
                  ),
                  labelText: 'Email',
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
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.vpn_key,
                    color: AppColors.black,
                  ),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
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
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          '/forgot-password'); // Tindakan saat tombol diklik
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.black),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text('OR')),
            const SizedBox(height: 10),
            // Tombol Google Sign-In sebagai IconButton
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Material(
                      shape: const CircleBorder(),
                      elevation: 2.0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24.0),
                        onTap: _isLoading ? null : _signInWithGoogle,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/icons/google_logo.png',
                            height: 24.0,
                            width: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tombol Login dengan Nomor Telepon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Material(
                      shape: const CircleBorder(),
                      elevation: 2.0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24.0),
                        onTap: _isLoading ? null : _navigateToPhoneSignInPage,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(Icons.phone),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi login dengan email dan password
  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Cek apakah email terverifikasi
      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          _showErrorDialog(
              'Your email has not been verified. Please check your email.');
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      }
    } catch (e) {
      _showErrorDialog('Login Failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi login dengan Google
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

  // Navigasi ke halaman Phone Sign-In
  void _navigateToPhoneSignInPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PhoneSignInPage()),
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
