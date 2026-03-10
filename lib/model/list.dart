class Lists {
  final int id;
  final int? taskId; // may be null when list has no associated task
  final int familyId;
  final String title;

  Lists({
    required this.id,
    this.taskId,
    required this.title,
    required this.familyId,
  });

  factory Lists.fromJson(Map<String, dynamic> json) {
    return Lists(
      id: json['id'],
      familyId: json['family_id'],
      title: json['title'],
      taskId: json['task_id'] as int?,
    );
  }
}