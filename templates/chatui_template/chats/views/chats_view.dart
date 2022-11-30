import 'package:bottom_street/app/services/responsive_size.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../services/common_image_view.dart';
import '../controllers/chats_controller.dart';

class ChatsView extends GetView<ChatsController> {
  const ChatsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.kw),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (context, index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () => controller.onChatTap(index),
                  child: Row(children: [
                    CircleAvatar(radius: 26.kh),
                    12.kwidthBox,
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name",
                          ),
                          2.kheightBox,
                          Text(
                            'Last Message',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    12.kwidthBox,
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '9:27pm',
                        ),
                        8.kheightBox,
                        CircleAvatar(
                          radius: 10.kh,
                          child: Text(
                            '2',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    )
                  ]),
                ),
                24.kheightBox
              ],
            );
          }),
    ));
  }
}
