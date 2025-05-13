import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class EncryptionController extends GetxController {
  var selectedFileName = ''.obs;
  var userEnteredKey = ''.obs;
  PlatformFile? selectedFile;

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      selectedFile = result.files.single;
      selectedFileName.value = selectedFile!.name;
      Get.snackbar('File Selected', selectedFileName.value);
    } else {
      Get.snackbar('Error', 'No file selected.');
    }
  }

  Future<void> generateAndDownloadKey() async {
    try {
      final res = await http.post(
        Uri.parse('http://localhost:8000/generate-key/'),
      );
      if (res.statusCode == 200) {
        final key = res.body;

        if (kIsWeb) {
          _downloadWebKeyFile(key);
        }

        Get.snackbar('Success', 'Key generated and downloaded.');
      } else {
        Get.snackbar('Error', 'Key generation failed: ${res.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error: $e');
    }
  }

  Future<void> encryptAndUpload() async {
    if (selectedFile == null) {
      Get.snackbar('Error', 'No file selected for encryption.');
      return;
    }

    if (userEnteredKey.value.isEmpty) {
      Get.snackbar('Error', 'Encryption key is empty.');
      return;
    }

    try {
      final uri = Uri.parse('http://localhost:8000/encrypt/');
      final req =
          http.MultipartRequest('POST', uri)
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                selectedFile!.bytes!,
                filename: selectedFile!.name,
              ),
            )
            ..fields['key'] = userEnteredKey.value;

      final res = await req.send();
      if (res.statusCode != 200) {
        final err = await res.stream.bytesToString();
        Get.snackbar('Error', 'Encryption failed: $err');
        return;
      }

      final encryptedBytes = await res.stream.toBytes();
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        Get.snackbar('Error', 'User not logged in.');
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${user.id}/encrypted_$timestamp${selectedFile!.name}';

      await supabase.storage
          .from('encrypted-files')
          .uploadBinary(filePath, encryptedBytes);

      await supabase.from('encrypted_files').insert({
        'user_id': user.id,
        'file_path': filePath,
        'original_name': selectedFile!.name,
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar('Success', 'File encrypted and uploaded successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    }
  }

  void _downloadWebKeyFile(String key) {
    if (kIsWeb) {
      final blob = html.Blob([key]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute("download", "qkey.txt")
            ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}
