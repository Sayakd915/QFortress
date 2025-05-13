import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qfortress/app/widgets/nav_drawer.dart';
import '../controllers/decryption_controller.dart';

class DecryptionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DecryptionController controller = Get.put(DecryptionController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          NavDrawer(),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(40),
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QFortress - Decryption',
                        style: GoogleFonts.raleway(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Decrypt Your Files',
                        style: GoogleFonts.raleway(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Select Encrypted File',
                        style: GoogleFonts.raleway(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Obx(
                        () => Container(
                          width: 300,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: DropdownButton<Map<String, dynamic>>(
                            value: controller.selectedFile.value,
                            isExpanded: true,
                            hint: Text(
                              controller.encryptedFiles.isEmpty
                                  ? 'No files available'
                                  : 'Select a file',
                              style: GoogleFonts.raleway(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            items:
                                controller.encryptedFiles.map((file) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: file,
                                    child: Text(
                                      file['original_name'] ?? 'Unnamed File',
                                      style: GoogleFonts.raleway(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (file) {
                              controller.selectedFile.value = file;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Enter AES Key (Binary String)',
                        style: GoogleFonts.raleway(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 500,
                        child: TextField(
                          onChanged:
                              (val) => controller.userEnteredKey.value = val,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter key from /generate-key/',
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: controller.decryptFile,
                            child: Text(
                              'Decrypt and Download',
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
                              minimumSize: Size(150, 50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
