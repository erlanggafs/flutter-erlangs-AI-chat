import 'package:erlangs_ai/presentation/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:erlangs_ai/presentation/pages/register_page.dart';
import 'package:erlangs_ai/presentation/widgets/google_signin_button.dart';
import 'package:erlangs_ai/presentation/widgets/phone_signin_button.dart';
import '../../constants/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _loginController = LoginController();
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
            // Input field untuk email dan password
            _buildEmailInput(),
            const SizedBox(height: 16.0),
            _buildPasswordInput(),
            _buildForgotPasswordButton(),
            _buildLoginButton(),
            const SizedBox(height: 10),
            const Center(child: Text('OR')),
            const SizedBox(height: 10),
            _buildAuthButtons(),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  // Fungsi-fungsi input dan button
  Widget _buildEmailInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: _loginController.emailController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.email, color: AppColors.black),
          labelText: 'Email',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: AppColors.black, width: 2.0),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: _loginController.passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key, color: AppColors.black),
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: AppColors.black, width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/forgot-password');
            },
            child: const Text('Forgot Password?',
                style: TextStyle(color: AppColors.black)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
        ),
        onPressed: () {
          _loginController.login(context);
        },
        child: _loginController.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Login'),
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        GoogleSignInButton(),
        SizedBox(width: 20),
        PhoneSignInButton(),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t have an account?'),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}
