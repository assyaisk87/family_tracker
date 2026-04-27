import 'family_user.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final String familyId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool completed;
  final List<FamilyUser> assignees;
  final int priority;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.familyId,
    required this.createdBy,
    required this.createdAt,
    this.dueDate,
    required this.completed,
    required this.assignees,
    required this.priority,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? familyId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? completed,
    List<FamilyUser>? assignees,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      familyId: familyId ?? this.familyId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      assignees: assignees ?? this.assignees,
      priority: priority ?? this.priority,
    );
  }
}