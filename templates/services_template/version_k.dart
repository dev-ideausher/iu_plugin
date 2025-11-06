import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

import 'responsive_size.dart';
import 'text_style_util.dart';
import 'colors.dart';
import 'dialog_helper.dart';

/// Advanced version update checker and manager
/// Note: Works only if app is released in all countries
/// For specific country, additional configuration is required
class VersionK {
  static VersionK? _instance;
  static VersionK get instance {
    _instance ??= VersionK._internal();
    return _instance!;
  }

  bool _checkedUpdates = false;
  String? _forceAppVersion;

  VersionK._internal();

  /// Set force app version for testing
  /// Only works in debug mode
  void setForceVersion(String? version) {
    if (kDebugMode) {
      _forceAppVersion = version;
      if (kDebugMode) {
        developer.log('Force version set to: $version');
      }
    }
  }

  /// Check for app updates
  /// Returns true if update is available, false otherwise
  Future<bool> checkForUpdate({bool showDialog = true}) async {
    if (_checkedUpdates) {
      if (kDebugMode) {
        developer.log('Updates already checked');
      }
      return false;
    }

    try {
      final newVersion = NewVersionPlus(
        forceAppVersion: _forceAppVersion,
      );

      final status = await newVersion.getVersionStatus();

      if (status == null || !status.canUpdate) {
        _checkedUpdates = true;
        return false;
      }

      final localVersion = _parseVersion(status.localVersion);
      final storeVersion = _parseVersion(status.storeVersion);

      // Check if major version update
      final isMajorUpdate = localVersion.major < storeVersion.major;

      if (showDialog) {
        showUpdateDialog(
          isMandatory: isMajorUpdate,
          localVersion: status.localVersion,
          storeVersion: status.storeVersion,
          releaseNotes: status.releaseNotes ?? '',
          appStoreLink: status.appStoreLink,
        );
      }

      _checkedUpdates = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error checking for updates: $e', error: e);
      }
      return false;
    }
  }

  /// Parse version string to Version object
  _Version _parseVersion(String version) {
    final parts = version.split('.');
    return _Version(
      major: int.tryParse(parts[0]) ?? 0,
      minor: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      patch: parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
    );
  }

  /// Show update dialog
  void showUpdateDialog({
    String title = 'New Update Available!',
    String? localVersion = '',
    String? storeVersion = '',
    bool isMandatory = false,
    String releaseNotes = '',
    required String appStoreLink,
    String? lottieAsset,
  }) {
    DialogHelper.hideDialog();

    Get.dialog(
      PopScope(
        canPop: !isMandatory,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.kh),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.kh),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyleUtil.genSans600(
                    color: Colors.black,
                    fontSize: 20.kh,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.kh),

                // Lottie animation
                if (lottieAsset != null)
                  Lottie.asset(
                    lottieAsset,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.contain,
                  )
                else
                  Icon(
                    Icons.system_update,
                    size: 64.kh,
                    color: Get.context?.brandColor1 ?? Colors.blue,
                  ),

                SizedBox(height: 16.kh),

                // Version info
                Text(
                  'Update available from $localVersion to $storeVersion',
                  style: TextStyleUtil.genSans400(
                    color: Colors.black87,
                    fontSize: 14.kh,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12.kh),

                // Update message
                Text(
                  isMandatory
                      ? 'This is a mandatory update. Please update now to continue using the app.'
                      : 'Would you like to update now?',
                  style: TextStyleUtil.genSans400(
                    color: Colors.black87,
                    fontSize: 14.kh,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Release notes
                if (releaseNotes.isNotEmpty) ...[
                  SizedBox(height: 16.kh),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What\'s New:',
                      style: TextStyleUtil.genSans600(
                        color: Colors.black,
                        fontSize: 14.kh,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.kh),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.kh),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.kh),
                    ),
                    child: Text(
                      releaseNotes,
                      style: TextStyleUtil.genSans400(
                        color: Colors.black87,
                        fontSize: 12.kh,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                SizedBox(height: 24.kh),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isMandatory)
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Later',
                          style: TextStyleUtil.genSans500(
                            color: Get.context?.brandColor1 ?? Colors.blue,
                            fontSize: 16.kh,
                          ),
                        ),
                      ),
                    SizedBox(width: 8.kw),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final uri = Uri.parse(appStoreLink);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (kDebugMode) {
                              developer.log('Cannot launch URL: $appStoreLink');
                            }
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            developer.log('Error launching URL: $e', error: e);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.context?.brandColor1 ?? Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.kw,
                          vertical: 12.kh,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.kh),
                        ),
                      ),
                      child: Text(
                        'Update Now',
                        style: TextStyleUtil.genSans600(
                          color: Colors.white,
                          fontSize: 16.kh,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: !isMandatory,
    );
  }

  /// Reset update check flag
  void resetUpdateCheck() {
    _checkedUpdates = false;
  }

  /// Get update check status
  bool get hasCheckedUpdates => _checkedUpdates;
}

/// Version data class
class _Version {
  final int major;
  final int minor;
  final int patch;

  _Version({
    required this.major,
    required this.minor,
    required this.patch,
  });

  @override
  String toString() => '$major.$minor.$patch';
}
