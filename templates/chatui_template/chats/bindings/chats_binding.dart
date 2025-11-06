import 'package:get/get.dart';

import '../controllers/chats_controller.dart';

/// Binding for Chats module
/// Handles dependency injection for ChatsController
class ChatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatsController>(
      () => ChatsController(),
      fenix: true, // Keep controller in memory even after disposal
    );
  }

  /// Dispose all dependencies
  static void dispose() {
    Get.delete<ChatsController>();
  }
}
