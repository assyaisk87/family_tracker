import '../../domain/entities/task_assignee.dart';
import '../../domain/repositories/task_assignees_repository.dart';
import '../datasources/task_assignees_remote_data_source.dart';
import '../models/task_assignee_model.dart';

class TaskAssigneesRepositoryImpl implements TaskAssigneesRepository {
  final TaskAssigneesRemoteDataSource remoteDataSource;

  TaskAssigneesRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> addTaskAssignees(List<TaskAssignee> assignees) async {
    final models = assignees
        .map((assignee) => TaskAssigneeModel.fromDomain(assignee))
        .toList();
    await remoteDataSource.addTaskAssignees(models);
  }

  @override
  Future<List<TaskAssignee>> getTaskAssignees(String taskId) async {
    final models = await remoteDataSource.fetchTaskAssignees(taskId);
    return models.map((model) => model.toDomain()).toList();
  }
}
