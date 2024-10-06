import 'package:flutter/material.dart';
import '../pages/phone_signin_page.dart';

class PhoneSignInButton extends StatelessWidget {
  const PhoneSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      elevation: 2.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PhoneSignInPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: const Icon(Icons.phone),
        ),
      ),
    );
  }
}
