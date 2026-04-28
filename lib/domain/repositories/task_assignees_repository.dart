import '../entities/task_assignee.dart';

abstract class TaskAssigneesRepository {
  Future<void> addTaskAssignees(List<TaskAssignee> assignees);
  Future<List<TaskAssignee>> getTaskAssignees(String taskId);
}
