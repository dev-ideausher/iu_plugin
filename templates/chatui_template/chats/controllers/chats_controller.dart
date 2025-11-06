import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/date_formatter.dart';

/// Chat item model
class ChatItem {
  final String id;
  final String name;
  final String? avatar;
  final String? lastMessage;
  final DateTime? timestamp;
  final int unreadCount;
  final bool isOnline;

  ChatItem({
    required this.id,
    required this.name,
    this.avatar,
    this.lastMessage,
    this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      lastMessage: json['lastMessage'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'lastMessage': lastMessage,
      'timestamp': timestamp?.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
    };
  }
}

/// Advanced Chats Controller with reactive state management
class ChatsController extends GetxController with GetTickerProviderStateMixin {
  // Reactive state
  final RxList<ChatItem> chats = <ChatItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<ChatItem> filteredChats = <ChatItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeChats();
  }

  @override
  void onReady() {
    super.onReady();
    loadChats();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Initialize chats
  void _initializeChats() {
    // Listen to search query changes
    ever(searchQuery, (query) {
      _filterChats(query);
    });
  }

  /// Load chats from API or local storage
  Future<void> loadChats() async {
    try {
      isLoading.value = true;

      // TODO: Load from API
      // final response = await APIManager.instance.get(
      //   endpoint: '/chats',
      //   parser: (data) {
      //     if (data is List) {
      //       return data.map((json) => ChatItem.fromJson(json)).toList();
      //     }
      //     return [];
      //   },
      // );
      //
      // if (response.success && response.data != null) {
      //   chats.value = response.data as List<ChatItem>;
      // }

      // Mock data for now
      chats.value = [
        ChatItem(
          id: '1',
          name: 'John Doe',
          lastMessage: 'Hey, how are you?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 2,
          isOnline: true,
        ),
        ChatItem(
          id: '2',
          name: 'Jane Smith',
          lastMessage: 'See you tomorrow!',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 0,
          isOnline: false,
        ),
      ];

      _filterChats(searchQuery.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load chats: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh chats list
  Future<void> refreshChats() async {
    await loadChats();
  }

  /// Filter chats based on search query
  void _filterChats(String query) {
    if (query.isEmpty) {
      filteredChats.value = chats;
      return;
    }

    filteredChats.value = chats.where((chat) {
      return chat.name.toLowerCase().contains(query.toLowerCase()) ||
          (chat.lastMessage?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Navigate to chat screen
  void onChatTap(int index) {
    final chat = filteredChats[index];
    Get.toNamed(Routes.CHAT_SCREEN, arguments: {'chatId': chat.id});
  }

  /// Delete chat
  Future<void> deleteChat(String chatId) async {
    try {
      // TODO: Delete from API
      // await APIManager.instance.delete(endpoint: '/chats/$chatId');
      
      chats.removeWhere((chat) => chat.id == chatId);
      _filterChats(searchQuery.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Mark chat as read
  Future<void> markAsRead(String chatId) async {
    try {
      final chatIndex = chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        final chat = chats[chatIndex];
        chats[chatIndex] = ChatItem(
          id: chat.id,
          name: chat.name,
          avatar: chat.avatar,
          lastMessage: chat.lastMessage,
          timestamp: chat.timestamp,
          unreadCount: 0,
          isOnline: chat.isOnline,
        );
        
        // TODO: Update on API
        // await APIManager.instance.put(
        //   endpoint: '/chats/$chatId/read',
        // );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking chat as read: $e');
      }
    }
  }
}
