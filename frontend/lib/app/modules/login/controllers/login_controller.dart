import 'package:get/get.dart';
import 'package:qfortress/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;

  void signIn() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.value,
        password: password.value,
      );

      if (response.user != null) {
        Get.toNamed(Routes.HOME);
      } else {
        final errorMessage = 'Sign in failed. Please check your credentials.';
        Get.snackbar(
          'Sign In Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Sign In Error',
        e.toString(), // Display the error message
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
