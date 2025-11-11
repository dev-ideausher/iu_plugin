// Freezed model example for API responses
// Required pubspec additions in your app:
// dependencies:
//   freezed_annotation: ^2.4.1
//   json_annotation: ^4.9.0
// dev_dependencies:
//   build_runner: ^2.4.11
//   freezed: ^2.5.7
//   json_serializable: ^6.9.0
//
// Then run:
// flutter pub run build_runner build --delete-conflicting-outputs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    String? avatar,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}


