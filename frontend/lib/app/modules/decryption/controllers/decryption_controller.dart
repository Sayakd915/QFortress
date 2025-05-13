import 'dart:html' as html;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class DecryptionController extends GetxController {
  var encryptedFiles = <Map<String, dynamic>>[].obs;
  var selectedFile = Rxn<Map<String, dynamic>>();
  var userEnteredKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEncryptedFiles();
  }

  Future<void> fetchEncryptedFiles() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not signed in');
        return;
      }

      final response = await Supabase.instance.client
          .from('encrypted_files')
          .select('file_path, original_name')
          .eq('user_id', user.id);

      encryptedFiles.value = List<Map<String, dynamic>>.from(response);
      if (encryptedFiles.isNotEmpty) {
        selectedFile.value = encryptedFiles.first;
      } else {
        Get.snackbar('Info', 'No encrypted files found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch files: $e');
    }
  }

  Future<void> decryptFile() async {
    if (selectedFile.value == null || userEnteredKey.isEmpty) {
      Get.snackbar('Error', 'File or key not provided');
      return;
    }

    try {
      final filePath = selectedFile.value!['file_path'];
      final originalName = selectedFile.value!['original_name'];

      final response = await Supabase.instance.client.storage
          .from('encrypted-files')
          .download(filePath);

      final uri = Uri.parse('http://localhost:8000/decrypt/');
      final req =
          http.MultipartRequest('POST', uri)
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                response,
                filename: originalName,
              ),
            )
            ..fields['key'] = userEnteredKey.value;

      final streamedRes = await req.send();
      if (streamedRes.statusCode != 200) {
        final error = await streamedRes.stream.bytesToString();
        Get.snackbar('Error', 'Decryption failed: $error');
        return;
      }

      final decryptedBytes = await streamedRes.stream.toBytes();

      final blob = html.Blob([decryptedBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute("download", originalName)
            ..click();
      html.Url.revokeObjectUrl(url);

      Get.snackbar('Success', 'File decrypted and downloaded.');
    } catch (e) {
      Get.snackbar('Error', 'Decryption error: $e');
    }
  }
}
