import 'package:get/get.dart';
import 'dart:developer' as developer;

import 'api_response.dart';
import 'endpoints.dart';
import 'local_data_source.dart';
import 'remote_data_source.dart';
import 'repository.dart';

/// Example User Model
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}

/// Example User Remote Data Source
class UserRemoteDataSource extends RemoteDataSource {
  /// Get user profile
  Future<ApiResponse<UserModel>> getUserProfile(String userId) async {
    return await get<UserModel>(
      endpoint: Endpoints.apiPath('/users/$userId'),
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update user profile
  Future<ApiResponse<UserModel>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    return await put<UserModel>(
      endpoint: Endpoints.apiPath('/users/$userId'),
      body: data,
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get user list
  Future<ApiResponse<List<UserModel>>> getUserList({
    int page = 1,
    int limit = 20,
  }) async {
    return await get<List<UserModel>>(
      endpoint: Endpoints.apiPath('/users'),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      parser: (data) {
        if (data is List) {
          return data.map((json) => 
            UserModel.fromJson(json as Map<String, dynamic>)
          ).toList();
        }
        return [];
      },
    );
  }
}

/// Example User Local Data Source
class UserLocalDataSource extends LocalDataSource {
  static const String _userCacheKey = 'user_cache';
  static const String _userListCacheKey = 'user_list_cache';

  /// Save user to cache
  Future<void> cacheUser(UserModel user) async {
    await save(_userCacheKey, user.toJson());
  }

  /// Get cached user
  UserModel? getCachedUser() {
    final data = get<Map<String, dynamic>>(_userCacheKey);
    if (data != null) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  /// Clear user cache
  Future<void> clearUserCache() async {
    await remove(_userCacheKey);
  }
}

/// Example User Repository following clean architecture
/// This demonstrates how to use the repository pattern
class UserRepository extends Repository {
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource? _localDataSource;

  UserRepository({
    required UserRemoteDataSource remoteDataSource,
    UserLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        super(
          remoteDataSource: remoteDataSource,
          localDataSource: localDataSource,
        );

  /// Get user profile with caching
  Future<ApiResponse<UserModel>> getUserProfile(String userId) async {
    return await executeWithCache<UserModel>(
      remoteCall: () => _remoteDataSource.getUserProfile(userId),
      cacheKey: 'user_profile_$userId',
      cacheDuration: const Duration(minutes: 5),
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update user profile
  Future<ApiResponse<UserModel>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _remoteDataSource.updateUserProfile(
      userId: userId,
      data: data,
    );

    // Clear cache after update
    if (response.success && _localDataSource != null) {
      await clearCache('user_profile_$userId');
    }

    return response;
  }

  /// Get user list with caching
  Future<ApiResponse<List<UserModel>>> getUserList({
    int page = 1,
    int limit = 20,
  }) async {
    return await executeWithCache<List<UserModel>>(
      remoteCall: () => _remoteDataSource.getUserList(
        page: page,
        limit: limit,
      ),
      cacheKey: 'user_list_$page',
      cacheDuration: const Duration(minutes: 10),
      parser: (data) {
        if (data is List) {
          return data.map((json) => 
            UserModel.fromJson(json as Map<String, dynamic>)
          ).toList();
        }
        return [];
      },
    );
  }

  /// Clear user cache
  Future<void> clearUserCache() async {
    if (_localDataSource != null) {
      await _localDataSource!.clearUserCache();
    }
    await clearAllCache();
  }
}

/// Dependency Injection setup example
/// This should be placed in your dependency injection file
class RepositoryLocator {
  static void setup() {
    // Register remote data sources
    Get.put<UserRemoteDataSource>(
      UserRemoteDataSource(),
      permanent: true,
    );

    // Register local data sources
    Get.put<UserLocalDataSource>(
      UserLocalDataSource(),
      permanent: true,
    );

    // Register repositories
    Get.put<UserRepository>(
      UserRepository(
        remoteDataSource: Get.find<UserRemoteDataSource>(),
        localDataSource: Get.find<UserLocalDataSource>(),
      ),
      permanent: true,
    );
  }
}

