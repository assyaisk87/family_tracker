class User {
  final String id;
  final String username;
  final String avatarUrl;
  final String email;
  final String familyId;

  User({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.email = '',
    this.familyId = '',
  });

  User copyWith({
    String? avatarUrl,
    String? username,
    String? email,
    String? familyId,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      familyId: familyId ?? this.familyId,
    );
  }
}
