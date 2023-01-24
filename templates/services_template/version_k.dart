import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:flutter/material.dart';
import 'package:ticket_box/services/responsive_size.dart';
import 'package:ticket_box/services/textstyles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Strings.dart';
import 'colors.dart';

///Note:  it will work only if app is released in all contries for particular country additional config is required
abstract class Versionk {
  bool checkedUpdates = false;

  Future<void> handleNewUpdate() async {
    checkedUpdates = false;
    try {
      final newVersion = NewVersionPlus(
          // forceAppVersion: kDebugMode ? '10.0.0' : null,
          ); //forceAppVersion: '4.0.2'
      final status = await newVersion.getVersionStatus();

      if (status != null) {
        if (int.parse(status.localVersion.split('.')[0]) < int.parse(status.storeVersion.split('.')[0]) && status.canUpdate) {
          showUpdateDialog(
              isMandatory: true, localver: status.localVersion, storever: status.storeVersion, releaseNote: status.releaseNotes ?? '', appStoreLink: status.appStoreLink);
        } else if (status.canUpdate) {
          showUpdateDialog(
              isMandatory: false, localver: status.localVersion, storever: status.storeVersion, releaseNote: status.releaseNotes ?? '', appStoreLink: status.appStoreLink);
          //minor update
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void showUpdateDialog(
      {String title = Strings.ksAPP_NAME + ' New Update!',
      String? localver = '',
      String? storever = '',
      bool isMandatory = false,
      String releaseNote = '',
      required String appStoreLink}) {
    hideDialog();
    Get.defaultDialog(
      titlePadding: EdgeInsets.only(top: 16.kh),
      title: title,
      content: Padding(
        padding: EdgeInsets.only(left: 8.0.kw, right: 8.0.kw, top: 8.0.kw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottiefiles/inAppUpdate.json',
              width: 100.w,
              height: 100,
              fit: BoxFit.fill,
            ),
            Container(
              child: Text(
                'Yay! there is new update from $localver to $storever',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.kh),
            Container(
              child: Text(
                isMandatory ? 'Please update now!' : 'Would you like to update?',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.kh),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(
                  'Release Note:',
                  style: TextStyleUtil.plusJakartaSansStyleS14W600(
                    color: ColorUtil.kdark,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(
                  releaseNote,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                isMandatory
                    ? const SizedBox()
                    : MaterialButton(
                        onPressed: () {
                          hideDialog();
                        },
                        child: Text(
                          'Later',
                          style: TextStyle(
                            color: ColorUtil.lightOrange,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                ElevatedButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse(appStoreLink));
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      ColorUtil.lightOrange,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.kh,
                        ),
                        side: BorderSide(
                          color: ColorUtil.lightOrange,
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Update Now',
                    style: TextStyle(
                      color: ColorUtil.kprimarywhite,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      radius: 10.0,
    );
  }

  //hide loading
  static Future<void> hideDialog() async {
    if (Get.isDialogOpen!) Get.until((route) => !Get.isDialogOpen!);
  }
}
