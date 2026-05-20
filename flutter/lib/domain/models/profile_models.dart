class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.providerIds,
    required this.isActive,
    required this.createdAt,
    required this.activatedAt,
    required this.lastLoginAt,
    required this.deletedAt,
  });

  final String id;
  final String email;
  final String displayName;
  final List<String> providerIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final DateTime? lastLoginAt;
  final DateTime? deletedAt;

  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      id: json['id']! as String,
      email: json['email']! as String,
      displayName: json['displayName']! as String,
      providerIds: (json['providerIds']! as List<Object?>).cast<String>(),
      isActive: json['isActive']! as bool,
      createdAt: DateTime.parse(json['createdAt']! as String),
      activatedAt: _dateOrNull(json['activatedAt']),
      lastLoginAt: _dateOrNull(json['lastLoginAt']),
      deletedAt: _dateOrNull(json['deletedAt']),
    );
  }
}

class UserStats {
  const UserStats({
    required this.dailyReadingCount,
    required this.deepReadingCount,
  });

  final int dailyReadingCount;
  final int deepReadingCount;

  factory UserStats.fromJson(Map<String, Object?> json) {
    return UserStats(
      dailyReadingCount: json['dailyReadingCount']! as int,
      deepReadingCount: json['deepReadingCount']! as int,
    );
  }
}

class ProfileSnapshot {
  const ProfileSnapshot({
    required this.user,
    required this.stats,
  });

  final UserProfile user;
  final UserStats stats;

  factory ProfileSnapshot.fromJson(Map<String, Object?> json) {
    return ProfileSnapshot(
      user: UserProfile.fromJson((json['user']! as Map).cast<String, Object?>()),
      stats: UserStats.fromJson((json['stats']! as Map).cast<String, Object?>()),
    );
  }
}

DateTime? _dateOrNull(Object? value) {
  return value is String ? DateTime.parse(value) : null;
}
