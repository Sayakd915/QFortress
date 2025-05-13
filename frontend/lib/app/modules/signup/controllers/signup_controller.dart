import 'package:get/get.dart';
import 'package:qfortress/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class SignupController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  void signUp() async {
    if (password.value != confirmPassword.value) {
      Get.snackbar(
        'Sign Up Error',
        'Passwords do not match.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.value,
        password: password.value,
      );

      if (response.user != null) {
        Get.toNamed(Routes.LOGIN);
      } else {
        final errorMessage = 'Sign up failed. Please try again.';
        Get.snackbar(
          'Sign Up Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Sign Up Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
