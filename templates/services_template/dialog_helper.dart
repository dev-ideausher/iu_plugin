import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart';
import 'responsive_size.dart';

/// Advanced Dialog Helper with comprehensive loading and dialog management
class DialogHelper {
  /// Show loading dialog with optional message
  /// [message] - Optional message to display below the loading indicator
  static void showLoading([String? message]) {
    if (Get.isDialogOpen == true) {
      return; // Already showing a dialog
    }

    Get.dialog(
      PopScope(
        canPop: false, // Prevent back button from closing
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(20.kh),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.kh),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8.kh),
                Container(
                  height: 60.kh,
                  width: 60.kh,
                  decoration: BoxDecoration(
                    color: Get.context?.brandColor1 ?? Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(12.kh),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                if (message != null && message.isNotEmpty) ...[
                  SizedBox(height: 16.kh),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14.kh,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 8.kh),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: const Color(0xff141A31).withOpacity(0.5),
      useSafeArea: true,
    );
  }

  /// Hide loading dialog
  static Future<void> hideDialog() async {
    if (Get.isDialogOpen == true) {
      try {
        Get.until((route) => !Get.isDialogOpen!);
      } catch (e) {
        // Dialog might have been closed already
        debugPrint('Error hiding dialog: $e');
      }
    }
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.kh),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.kh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.kh,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.kh),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.kh,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.kh),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        color: cancelColor ?? Colors.grey,
                        fontSize: 14.kh,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? Get.context?.brandColor1 ?? Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.kw,
                        vertical: 12.kh,
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.kh,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  /// Show info dialog
  static Future<void> showInfo({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.kh),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.kh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.kh,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.kh),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.kh,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.kh),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.context?.brandColor1 ?? Colors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.kw,
                    vertical: 12.kh,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.kh,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show error dialog
  static Future<void> showError({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.kh),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.kh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48.kh,
              ),
              SizedBox(height: 16.kh),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.kh,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16.kh),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.kh,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.kh),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.kw,
                    vertical: 12.kh,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.kh,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
