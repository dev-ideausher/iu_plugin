import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/responsive_size.dart';
import '../../../services/common_image_view.dart';
import '../../../services/text_style_util.dart';
import '../../../services/date_formatter.dart';
import '../controllers/chats_controller.dart';

/// Chats list view
/// Displays list of chat conversations
/// TODO: Add this page in routes file
class ChatsView extends GetView<ChatsController> {
  const ChatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyleUtil.genSans600(
            color: Colors.white,
            fontSize: 20.kh,
          ),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64.kh,
                  color: Colors.grey[400],
                ),
                16.kheightBox,
                Text(
                  'No chats yet',
                  style: TextStyleUtil.genSans400(
                    color: Colors.grey[600],
                    fontSize: 16.kh,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshChats,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.kw, vertical: 8.kh),
            itemCount: controller.filteredChats.length,
            itemBuilder: (context, index) {
              final chat = controller.filteredChats[index];
              return _buildChatItem(context, chat, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatItem chat, int index) {
    return InkWell(
      onTap: () => controller.onChatTap(index),
      borderRadius: BorderRadius.circular(12.kh),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.kh, horizontal: 8.kw),
        margin: EdgeInsets.only(bottom: 8.kh),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.kh),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 26.kh,
                  backgroundColor: Colors.grey[300],
                  child: chat.avatar != null
                      ? CommonImageView(
                          imagePath: chat.avatar!,
                          height: 52.kh,
                          width: 52.kw,
                          radius: BorderRadius.circular(26.kh),
                        )
                      : Icon(
                          Icons.person,
                          size: 26.kh,
                          color: Colors.grey[600],
                        ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12.kw,
                      height: 12.kh,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            12.kwidthBox,

            // Chat info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: TextStyleUtil.genSans600(
                      color: Colors.black,
                      fontSize: 16.kh,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.kheightBox,
                  Text(
                    chat.lastMessage ?? 'No messages',
                    style: TextStyleUtil.genSans400(
                      color: Colors.grey[600],
                      fontSize: 14.kh,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            12.kwidthBox,

            // Time and badge
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chat.timestamp != null)
                  Text(
                    DateFormatter.formatRelative(chat.timestamp!),
                    style: TextStyleUtil.genSans400(
                      color: Colors.grey[500],
                      fontSize: 12.kh,
                    ),
                  ),
                if (chat.unreadCount > 0) ...[
                  8.kheightBox,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.kw,
                      vertical: 4.kh,
                    ),
                    decoration: BoxDecoration(
                      color: Get.context?.brandColor1 ?? Colors.blue,
                      borderRadius: BorderRadius.circular(12.kh),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: TextStyleUtil.genSans600(
                        color: Colors.white,
                        fontSize: 12.kh,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
