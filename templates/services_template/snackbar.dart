import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Snackbar type enumeration
enum SnackbarType {
  success,
  error,
  warning,
  info,
}

/// Advanced Snackbar utility with multiple types and configurations
class SnackbarHelper {
  /// Show success snackbar
  static void showSuccess({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
    VoidCallback? onTap,
  }) {
    _showSnackbar(
      message: message,
      title: title ?? 'Success',
      type: SnackbarType.success,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Show error snackbar
  static void showError({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
    VoidCallback? onTap,
  }) {
    _showSnackbar(
      message: message,
      title: title ?? 'Error',
      type: SnackbarType.error,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
    VoidCallback? onTap,
  }) {
    _showSnackbar(
      message: message,
      title: title ?? 'Warning',
      type: SnackbarType.warning,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Show info snackbar
  static void showInfo({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
    VoidCallback? onTap,
  }) {
    _showSnackbar(
      message: message,
      title: title ?? 'Info',
      type: SnackbarType.info,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Show custom snackbar
  static void showCustom({
    required String message,
    String? title,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    SnackPosition? position,
    VoidCallback? onTap,
  }) {
    if (Get.isSnackbarOpen == true) return;

    Get.snackbar(
      title ?? '',
      message,
      backgroundColor: backgroundColor ?? Colors.grey[800],
      colorText: textColor ?? Colors.white,
      icon: icon != null ? Icon(icon, color: textColor ?? Colors.white) : null,
      duration: duration ?? const Duration(seconds: 3),
      snackPosition: position ?? SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      onTap: onTap != null ? (_) => onTap() : null,
    );
  }

  /// Internal method to show snackbar with type
  static void _showSnackbar({
    required String message,
    String? title,
    required SnackbarType type,
    Duration? duration,
    SnackPosition? position,
    VoidCallback? onTap,
  }) {
    if (Get.isSnackbarOpen == true) return;

    final config = _getSnackbarConfig(type);

    Get.snackbar(
      title ?? config.title,
      message,
      backgroundColor: config.backgroundColor,
      colorText: config.textColor,
      icon: Icon(config.icon, color: config.textColor),
      duration: duration ?? config.duration,
      snackPosition: position ?? SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      onTap: onTap != null ? (_) => onTap() : null,
      snackStyle: SnackStyle.FLOATING,
      titleText: title != null
          ? Text(
              title,
              style: TextStyle(
                color: config.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          : null,
      messageText: Text(
        message,
        style: TextStyle(
          color: config.textColor,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Get snackbar configuration based on type
  static _SnackbarConfig _getSnackbarConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          backgroundColor: Colors.green,
          textColor: Colors.white,
          icon: Icons.check_circle,
          title: 'Success',
          duration: const Duration(seconds: 3),
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          icon: Icons.error,
          title: 'Error',
          duration: const Duration(seconds: 4),
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          icon: Icons.warning,
          title: 'Warning',
          duration: const Duration(seconds: 3),
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          icon: Icons.info,
          title: 'Info',
          duration: const Duration(seconds: 3),
        );
    }
  }
}

/// Snackbar configuration
class _SnackbarConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String title;
  final Duration duration;

  _SnackbarConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.title,
    required this.duration,
  });
}

/// Legacy function for backward compatibility
void showMySnackbar({String? title, required String msg}) {
  SnackbarHelper.showInfo(
    message: msg,
    title: title,
  );
}
