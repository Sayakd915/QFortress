import 'package:get/get.dart';
import 'package:qfortress/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  var email = ''.obs;
  var joinedDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        email.value = user.email ?? 'No email available';
        joinedDate.value = user.createdAt.toString();
      } else {
        Get.snackbar(
          'Error',
          'No user is currently signed in.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error fetching user profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Get.snackbar(
        'Success',
        'Signed out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(Routes.SIGNUP);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error signing out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
