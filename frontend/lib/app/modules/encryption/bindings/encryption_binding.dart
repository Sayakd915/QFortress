import 'package:get/get.dart';

import '../controllers/encryption_controller.dart';

class EncryptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EncryptionController>(
      () => EncryptionController(),
    );
  }
}
