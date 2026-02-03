import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String timezone;

  @HiveField(4)
  final Map<String, dynamic> soundPreferences;

  @HiveField(5)
  bool isPremium;

  @HiveField(6)
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.email,
    this.displayName,
    required this.timezone,
    this.soundPreferences = const {},
    this.isPremium = false,
    required this.createdAt,
  });

  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? timezone,
    Map<String, dynamic>? soundPreferences,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      timezone: timezone ?? this.timezone,
      soundPreferences: soundPreferences ?? this.soundPreferences,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
