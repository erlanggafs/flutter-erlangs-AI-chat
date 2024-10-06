import 'package:erlangs_ai/presentation/controllers/phone_sign_in_controller.dart';
import 'package:erlangs_ai/presentation/widgets/phone_sign_in_widget.dart';
import 'package:flutter/material.dart';

class PhoneSignInPage extends StatelessWidget {
  const PhoneSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PhoneSignInController(); // Instansiasi controller

    return PhoneSignInWidget(controller: controller); // Gunakan widget
  }
}
