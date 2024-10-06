import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        print("Login Succes!");
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Error: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Simpan verificationId untuk verifikasi OTP nanti
        print("OTP sent. ID verification: $verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Timeout for ID verification: $verificationId");
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
      print("OTP successfully verified and login successful!");
    } catch (e) {
      print("OTP verification failed: $e");
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
