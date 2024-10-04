import 'package:erlangs_ai/chat_page.dart';
import 'package:erlangs_ai/firebase_options.dart';
import 'package:erlangs_ai/login_page.dart';
import 'package:erlangs_ai/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat variabel lingkungan
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Erlangs AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  return const ChatPage();
                }
                return const LoginPage();
              },
            ),
        '/login': (context) => const LoginPage(),
        '/chat': (context) => const ChatPage(),
        '/phoneSignIn': (context) => PhoneSignIn(), // Route untuk PhoneSignIn
      },
    );
  }
}

// Fungsi untuk mendaftar dan mengirim verifikasi email
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerWithEmail(String email, String password) async {
    try {
      // Buat pengguna baru
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kirim email verifikasi
      User? user = userCredential.user;
      await user?.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  // Cek apakah pengguna sudah memverifikasi email
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    return user != null && user.emailVerified;
  }

  // Tambahkan fungsi login dengan nomor telepon
  Future<void> signInWithPhone(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Login sukses!");
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Error: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Simpan verificationId untuk verifikasi OTP nanti
        print("OTP dikirim. Verifikasi ID: $verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Timeout untuk verifikasi ID: $verificationId");
      },
    );
  }

  // Fungsi untuk verifikasi OTP
  Future<void> verifyOTP(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in dengan credential
      await _auth.signInWithCredential(credential);
      print("OTP berhasil diverifikasi dan login sukses!");
    } catch (e) {
      print("Verifikasi OTP gagal: $e");
    }
  }
}

// Fungsi Google Sign-In
Future<User?> signInWithGoogle() async {
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
    return userCredential.user;
  }

  return null;
}

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
        print("Login sukses!");
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
        print("Login sukses dengan OTP!");
      } catch (e) {
        print("Verifikasi OTP gagal: $e");
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
