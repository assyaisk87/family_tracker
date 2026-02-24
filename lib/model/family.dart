class FamilyModel {
  final int id;
  final String name;
  final String inviteCode;
  final DateTime? createdAt;

  FamilyModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'],
      name: json['name'],
      inviteCode: json['invite_code'],
      createdAt: json['created_at'] != null    ? DateTime.parse(json['created_at'] as String)    : null,
    );
  }
}
