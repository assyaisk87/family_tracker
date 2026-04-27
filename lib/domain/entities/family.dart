class Family {
  final String id;
  final String name;
  final String inviteCode;
  final DateTime createdAt;

  const Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
  });

  Family copyWith({
    String? id,
    String? name,
    String? inviteCode,
    DateTime? createdAt,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
 
}