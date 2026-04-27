class FamilyUser {
  final String id;
  final String familyId;
  final String userId;
  final bool role;
  final String displayName;
  final String avatarUrl;

  const FamilyUser({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.displayName,
    required this.avatarUrl,
  });

  FamilyUser copyWith({
    String? id,
    String? familyId,
    String? userId,
    bool? role,
    String? displayName,
    String? avatarUrl,
  }) {
    return FamilyUser(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}