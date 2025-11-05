import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Chat message model
class ChatMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool isSent;
  final String? senderId;
  final String? senderName;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isSent,
    this.senderId,
    this.senderName,
    this.imageUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isSent: json['isSent'] as bool? ?? false,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isSent': isSent,
      'senderId': senderId,
      'senderName': senderName,
      'imageUrl': imageUrl,
    };
  }
}

/// Advanced Chat Screen Controller with reactive state management
class ChatScreenController extends GetxController {
  // Text editing controller
  final TextEditingController messageController = TextEditingController();
  
  // Reactive state
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString chatId = ''.obs;
  final RxString recipientId = ''.obs;
  final RxString recipientName = ''.obs;
  final Rx<ScrollController?> scrollController = Rx<ScrollController?>(null);

  @override
  void onInit() {
    super.onInit();
    scrollController.value = ScrollController();
    _initializeChat();
  }

  @override
  void onReady() {
    super.onReady();
    // Scroll to bottom on ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.value?.dispose();
    super.onClose();
  }

  /// Initialize chat
  void _initializeChat() {
    // TODO: Load chat messages from API or local storage
    // Example:
    // loadMessages();
  }

  /// Send message
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    try {
      isSending.value = true;
      
      // Create message
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: text,
        timestamp: DateTime.now(),
        isSent: true,
        senderId: 'current_user_id', // TODO: Get from storage
        senderName: 'You', // TODO: Get from storage
      );

      // Add to local list immediately for optimistic UI
      messages.add(message);
      messageController.clear();

      // Scroll to bottom
      _scrollToBottom();

      // TODO: Send to API
      // final response = await APIManager.post(
      //   endpoint: '/chat/send',
      //   body: message.toJson(),
      // );
      // 
      // if (!response.success) {
      //   // Remove message if failed
      //   messages.remove(message);
      //   // Show error
      //   Get.snackbar('Error', 'Failed to send message');
      // }

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Handle error
      Get.snackbar(
        'Error',
        'Failed to send message: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  /// Load messages
  Future<void> loadMessages() async {
    try {
      isLoading.value = true;
      
      // TODO: Load messages from API
      // final response = await APIManager.get(
      //   endpoint: '/chat/messages',
      //   queryParameters: {'chatId': chatId.value},
      // );
      // 
      // if (response.success && response.data != null) {
      //   final List<dynamic> messagesData = response.data as List<dynamic>;
      //   messages.value = messagesData
      //       .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
      //       .toList();
      // }

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load messages: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Scroll to bottom of chat
  void _scrollToBottom() {
    if (scrollController.value != null && scrollController.value!.hasClients) {
      scrollController.value!.animateTo(
        scrollController.value!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      // Remove from local list
      messages.removeWhere((msg) => msg.id == messageId);

      // TODO: Delete from API
      // await APIManager.delete(
      //   endpoint: '/chat/messages/$messageId',
      // );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete message',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Clear chat
  void clearChat() {
    messages.clear();
    messageController.clear();
  }
}
