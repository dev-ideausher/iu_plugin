import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class ChatsController extends GetxController with GetTickerProviderStateMixin {


  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  onChatTap(int index) {
    Get.toNamed(Routes.CHAT_SCREEN);
  }
}
