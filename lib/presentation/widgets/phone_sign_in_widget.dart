import 'package:erlangs_ai/presentation/controllers/phone_sign_in_controller.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart'; // Import controller

class PhoneSignInWidget extends StatelessWidget {
  final PhoneSignInController controller;

  const PhoneSignInWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Sign-In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Masukkan nomor telepon Anda'),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: controller.phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixText: '+62 ',
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
            if (controller.isOTPRequested)
              TextField(
                controller: controller.otpController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 5.0),
            ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : (controller.isOTPRequested
                      ? () => controller.verifyOTP(context)
                      : () => controller.sendOTP(context)),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary, // Ubah warna latar belakang di sini
                  foregroundColor: AppColors.white),
              child: controller.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(controller.isOTPRequested
                      ? 'Verifikasi OTP'
                      : 'Kirim OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
