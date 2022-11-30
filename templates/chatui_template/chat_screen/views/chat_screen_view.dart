import '../../../services/common_image_view.dart';
import '../../../services/responsive_size.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/chat_screen_controller.dart';

class ChatScreenView extends GetView<ChatScreenController> {
  const ChatScreenView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.kw),
        child: Column(
          //  crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            YourCustomizedContainer(
                isBorder: true,
                borderRadius: 4.kh,
                // borderColor: ColorUtil.brandLightRed1,
                // color: ColorUtil.brandLightRed1.withOpacity(0.5),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.kw, vertical: 8.kh),
                  child: RichText(
                    text: TextSpan(text: '${'note'.tr}: ',
                        // style: TextStyleUtil.textNunintoSansW700(
                        //     fontSize: 16.kh, color: const Color(0xffD62A3D)),
                        children: [
                          TextSpan(
                            text: '${'chat_warning'.tr} 5%. ',
                            // style: TextStyleUtil.textNunintoSansW400(
                            //     fontSize: 16.kh,
                            //     color: const Color(0xffD62A3D)),
                          ),
                          TextSpan(
                            text: '${'task_will_be'.tr} 7:00 PM',
                          ),
                        ]),
                  ),
                )),
            const Spacer(),
            Text(
              'today'.tr,
              // style: TextStyleUtil.textNunintoSansW700(fontSize: 16.kh),
            ),
            32.kheightBox,
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(maxWidth: 280.kw),
                decoration: BoxDecoration(
                  // color: ColorUtil.brandLightBlue3,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(2.kh),
                    bottomRight: Radius.circular(20.kh),
                    topRight: Radius.circular(20.kh),
                    topLeft: Radius.circular(20.kh),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.kw, vertical: 12.kh),
                  child: Text(
                    'I have arrived here at your requested location waiting for the clients to arrive and make a deal.',
                    // style: TextStyleUtil.textNunintoSansW400(fontSize: 16.kh),
                  ),
                ),
              ),
            ),
            12.kheightBox,
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  // color: ColorUtil.brandColor1,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.kh),
                    bottomRight: Radius.circular(2.kh),
                    topRight: Radius.circular(20.kh),
                    topLeft: Radius.circular(20.kh),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.kw, vertical: 12.kh),
                  child: Text(
                    'Good work! Carry on',
                    // style: TextStyleUtil.textNunintoSansW400(
                    //     fontSize: 16.kh, color: Colors.white),
                  ),
                ),
              ),
            ),
            12.kheightBox,
            YourCustomizedTextFiled(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonImageView(
                      // svgPath: ImageConstant.imgFile20X16,
                      height: 24.kh,
                      width: 24.kh,
                      fit: BoxFit.contain,
                    ),
                    24.kwidthBox,
                    CommonImageView(
                      // svgPath: ImageConstant.imgSend,
                      height: 24.kh,
                      width: 24.kh,
                      fit: BoxFit.contain,
                    ),
                    16.kwidthBox
                  ],
                ),
                hint: 'message'.tr,
                label: 'label',
                isLabel: false,
                controller: controller.messageController),
            28.kheightBox
          ],
        ),
      ),
    );
  }
}
