import 'package:get/get.dart';

void showMySnackbar({required String title, required String msg}) {
  Get.isSnackbarOpen == true ? Get.back() : null;
  Get.showSnackbar(
    GetSnackBar(
      title: title,
      message: msg,
      duration: const Duration(milliseconds: 2000),
    ),
  );
}
