import 'package:get/get.dart';

import '../controllers/decryption_controller.dart';

class DecryptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DecryptionController>(
      () => DecryptionController(),
    );
  }
}
