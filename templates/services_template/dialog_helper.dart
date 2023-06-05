import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart';
import 'responsive_size.dart';

class DialogHelper {
  static void showLoading([String? message]) {
    Get.dialog(
      WillPopScope(
        child: SizedBox(
          child: Column(
            children: [
              SizedBox(height: 60.h),
              Center(
                child: Container(
                    height: 80.kh,
                    width: 80.kh,
                    decoration: BoxDecoration(
                      color: Get.context!.brandColor1,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0.kh),
                      ),
                    ),
                    padding: EdgeInsets.all(12.kh),
                    child: Center(
                      child: CircularProgressIndicator(),
                    )),
              ),
              // message != null ? SizedBox(height: 8.kh) : const SizedBox(),
              // message != null ? Text(message) : const SizedBox(),
            ],
          ),
        ),
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      barrierColor: const Color(0xff141A31).withOpacity(.4),
      useSafeArea: true,
    );
  }

  //hide loading
  static Future<void> hideDialog() async {
    if (Get.isDialogOpen!) Get.until((route) => !Get.isDialogOpen!);
  }
}
