import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  var files = <String>[].obs;

  Future<void> refreshFiles() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in.');
      return;
    }

    try {
      final response = await Supabase.instance.client.storage
          .from('encrypted-files')
          .list(path: userId);

      files.value = response.map((item) => item.name).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load files: $e');
    }
  }
}
