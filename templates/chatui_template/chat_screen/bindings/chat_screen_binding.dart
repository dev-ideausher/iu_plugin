import 'package:get/get.dart';

import '../controllers/chat_screen_controller.dart';

/// Binding for Chat Screen module
/// Handles dependency injection for ChatScreenController
class ChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatScreenController>(
      () => ChatScreenController(),
      fenix: true, // Keep controller in memory even after disposal
    );
  }

  /// Dispose all dependencies
  static void dispose() {
    Get.delete<ChatScreenController>();
  }
}
