# Advanced Dio Template - Clean Architecture

This template provides a production-ready API layer following clean architecture principles.

## Architecture Overview

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  (Controllers, Views, Widgets)     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Repository Layer                │
│  (Business Logic, Caching)           │
└──────────────┬──────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
┌───▼──────┐      ┌──────▼──────┐
│  Remote  │      │    Local    │
│  Data    │      │    Data     │
│  Source  │      │   Source    │
└───┬──────┘      └──────┬──────┘
    │                     │
┌───▼─────────────────────▼──────┐
│      Data Layer                 │
│  (DioClient, Storage, Network)  │
└─────────────────────────────────┘
```

## Key Components

### 1. RemoteDataSource
Base class for all API calls. Handles HTTP requests, error handling, and response parsing.

### 2. LocalDataSource
Base class for local storage operations. Provides caching and offline data management.

### 3. Repository
Combines remote and local data sources with automatic caching strategies.

### 4. APIManager
Singleton API manager for quick API calls without full repository setup.

## Usage Examples

### Simple Usage (APIManager)

```dart
final response = await APIManager.instance.get<UserModel>(
  endpoint: '/users/123',
  parser: (data) => UserModel.fromJson(data),
);

if (response.success) {
  final user = response.data!;
  // Use user data
}
```

### Advanced Usage (Repository Pattern)

```dart
// 1. Create Remote Data Source
class UserRemoteDataSource extends RemoteDataSource {
  Future<ApiResponse<UserModel>> getUser(String id) async {
    return await get<UserModel>(
      endpoint: '/users/$id',
      parser: (data) => UserModel.fromJson(data),
    );
  }
}

// 2. Create Local Data Source
class UserLocalDataSource extends LocalDataSource {
  Future<void> cacheUser(UserModel user) async {
    await save('user_${user.id}', user.toJson());
  }
}

// 3. Create Repository
class UserRepository extends Repository {
  final UserRemoteDataSource _remote;
  final UserLocalDataSource _local;

  UserRepository(this._remote, this._local)
      : super(remoteDataSource: _remote, localDataSource: _local);

  Future<ApiResponse<UserModel>> getUser(String id) async {
    return await executeWithCache<UserModel>(
      remoteCall: () => _remote.getUser(id),
      cacheKey: 'user_$id',
      cacheDuration: Duration(minutes: 5),
      parser: (data) => UserModel.fromJson(data),
    );
  }
}
```

## Features

### ✅ Network Connectivity
- Automatic network status monitoring
- Offline request queuing
- Network-aware operations

### ✅ Retry Mechanism
- Exponential backoff
- Configurable retry policies
- Smart retry logic

### ✅ Request Logging
- Comprehensive request/response logging
- Configurable log levels
- Sensitive data masking

### ✅ Rate Limiting
- Per-endpoint rate limiting
- Automatic request throttling
- Configurable limits

### ✅ Caching
- Automatic response caching
- Cache expiration
- Cache invalidation

### ✅ Error Handling
- Comprehensive error types
- User-friendly error messages
- Error recovery strategies

### ✅ Mock Data Source
- Testing support
- Development mode
- Configurable delays

## Best Practices

1. **Always use Repository pattern** for complex features
2. **Use APIManager** for simple one-off requests
3. **Implement proper error handling** in repositories
4. **Use caching** for frequently accessed data
5. **Monitor network status** before making requests
6. **Use rate limiting** for high-frequency endpoints
7. **Log requests** in development for debugging

## Dependencies

Make sure to add these to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.0.0
  get: ^4.6.0
  get_storage: ^2.1.0
  connectivity_plus: ^5.0.0
  intl: ^0.18.0
```

## Initialization

```dart
// In main.dart
Future<void> initGetServices() async {
  // Initialize storage
  await Get.putAsync<GetStorageService>(
    () => GetStorageService().initState(),
    permanent: true,
  );

  // Initialize network connectivity
  await NetworkConnectivity.instance.initialize();

  // Setup repositories
  RepositoryLocator.setup();
}
```

## Testing

Use `MockRemoteDataSource` for testing:

```dart
final mockDataSource = MockRemoteDataSource();
mockDataSource.registerMockData<UserModel>(
  endpoint: '/users/123',
  data: UserModel(id: '123', name: 'Test'),
);

final repository = UserRepository(mockDataSource, null);
final response = await repository.getUser('123');
```

