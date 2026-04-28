import '../../domain/entities/task_assignee.dart';

class TaskAssigneeModel {
  final String? id;
  final String taskId;
  final String memberId;

  TaskAssigneeModel({
    this.id,
    required this.taskId,
    required this.memberId,
  });

  factory TaskAssigneeModel.fromDomain(TaskAssignee assignee) {
    return TaskAssigneeModel(
      id: assignee.id,
      taskId: assignee.taskId,
      memberId: assignee.memberId,
    );
  }

  TaskAssignee toDomain() {
    return TaskAssignee(
      id: id,
      taskId: taskId,
      memberId: memberId,
    );
  }

  factory TaskAssigneeModel.fromJson(Map<String, dynamic> json) {
    return TaskAssigneeModel(
      id: json['id']?.toString(),
      taskId: json['task_id']?.toString() ?? '',
      memberId: json['member_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (taskId.isNotEmpty) 'task_id': int.parse(taskId),
      if (memberId.isNotEmpty) 'member_id': int.parse(memberId),
    };
  }
}
