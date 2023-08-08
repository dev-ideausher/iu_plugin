import 'package:get/get.dart';

void showMySnackbar({String? title, required String msg}) {
  Get.isSnackbarOpen == true
      ? null
      : Get.rawSnackbar(
          title: title,
          message: msg,
          duration: const Duration(milliseconds: 2000),
        );
}
