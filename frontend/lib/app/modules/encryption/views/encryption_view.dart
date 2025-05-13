import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qfortress/app/widgets/nav_drawer.dart';
import '../controllers/encryption_controller.dart';

class EncryptionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EncryptionController controller = Get.put(EncryptionController());

    return Scaffold(
      body: Row(
        children: [
          NavDrawer(),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QFortress - Encryption',
                    style: GoogleFonts.raleway(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Encrypt Your Files',
                    style: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.generateAndDownloadKey,
                    child: Text(
                      'Generate and Download Key',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Key Input Field
                  Text(
                    'Enter Encryption Key',
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Obx(
                    () => TextField(
                      onChanged: (val) => controller.userEnteredKey.value = val,
                      controller: TextEditingController(
                          text: controller.userEnteredKey.value,
                        )
                        ..selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: controller.userEnteredKey.value.length,
                          ),
                        ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Paste your key here',
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // File Upload Section
                  Text(
                    'Upload File to Encrypt',
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: controller.uploadFile,
                        child: Text(
                          'Select File',
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Obx(
                        () => Text(
                          controller.selectedFileName.value.isEmpty
                              ? 'No file selected'
                              : controller.selectedFileName.value,
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Encrypt and Upload Button
                  ElevatedButton(
                    onPressed: controller.encryptAndUpload,
                    child: Text(
                      'Encrypt and Upload',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      minimumSize: Size(200, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
