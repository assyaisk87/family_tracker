class Task {
  final int id;
  final int familyId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool completed;
  final int createdBy;
  final List<int> assignees;

  Task({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    this.dueDate,
    required this.completed,
    required this.createdBy,
    required this.assignees,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      familyId: json['family_id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      completed: json['completed'] ?? false,
      createdBy: json['created_by'],
      assignees: (json['task_assignees'] as List?)
              ?.map((e) => e['member_id'] as int)
              .toList() ??
          [],
    );
  }
}
