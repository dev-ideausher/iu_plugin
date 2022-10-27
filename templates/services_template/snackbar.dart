import 'package:get/get.dart';

void showMySnackbar({required String title, required String msg}) {
  Get.isSnackbarOpen == true
      ? null
      : Get.snackbar(
          title,
          msg,
          duration: const Duration(milliseconds: 2000),
        );
}
