import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task.dart';
import 'family_user_model.dart';

part 'task_model.freezed.dart';

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    String? description,
    required String familyId,
    required String createdBy,
    required DateTime createdAt,
    DateTime? dueDate,
    required bool completed,
    required List<FamilyUserModel> assignees,
    required int priority,

  }) = _TaskModel;

  const TaskModel._();

  factory TaskModel.fromDomain(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      familyId: task.familyId,
      createdBy: task.createdBy,
      createdAt: task.createdAt,
      dueDate: task.dueDate,
      completed: task.completed,
      assignees: task.assignees.map((a) => FamilyUserModel.fromDomain(a)).toList(),
      priority: task.priority,

    );
  }

  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      familyId: familyId,
      createdBy: createdBy,
      createdAt: createdAt,
      dueDate: dueDate,
      completed: completed,
      assignees: assignees.map((a) => a.toDomain()).toList(),
      priority:   priority,
    );
  }
}
