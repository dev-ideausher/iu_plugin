import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/services/responsive_size.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.title.value)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Template is running'),
            16.kheightBox,
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.CHAT_SCREEN),
              child: const Text('Open Chat'),
            ),
          ],
        ),
      ),
    );
  }
}


