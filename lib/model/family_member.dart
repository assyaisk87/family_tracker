class FamilyMember {
  final int id;
  final int familyId;
  final String userId;
  final bool role;
  final String? displayName;
  final String avatarUrl;

  FamilyMember({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.displayName,
    required this.avatarUrl,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      familyId: json['family_id'],
      userId: json['user_id'],
      role: json['role'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}
