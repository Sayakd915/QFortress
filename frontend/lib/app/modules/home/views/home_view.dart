import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qfortress/app/widgets/nav_drawer.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    controller.refreshFiles();

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
                    'QFortress - Cloud Storage',
                    style: GoogleFonts.raleway(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your Stored Files',
                    style: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      final files = controller.files;
                      if (files.isEmpty) {
                        return Center(
                          child: Text(
                            'No files to display.',
                            style: GoogleFonts.raleway(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.insert_drive_file),
                            title: Text(files[index]),
                          );
                        },
                      );
                    }),
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
