import '../../domain/entities/family_user.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_assignee.dart';
import '../../domain/repositories/task_assignees_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskAssigneesRepository taskAssigneesRepository;

  TaskRepositoryImpl(this.remoteDataSource, this.taskAssigneesRepository);

  @override
  Future<void> addTask(Task task) async {
    await remoteDataSource.addTask(taskModelFromDomain(task));
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final task = await remoteDataSource.fetchTaskById(id);
    return task?.toDomain();
  }

  @override
  Future<List<Task>> getTasks() async {
    final tasks = await remoteDataSource.fetchTasks();
    return tasks.map((it) => it.toDomain()).toList();
  }

  @override
  Future<List<FamilyUser>> getParticipants() async {
    final users = await remoteDataSource.fetchParticipants();
    return users.map((it) => it.toDomain()).toList();
  }

  @override
  Future<void> toggleTaskDone(String taskId) async {
    await remoteDataSource.toggleTaskDone(taskId);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await remoteDataSource.deleteTask(taskId);
  }

  @override
  Future<void> updateTask(Task task) async {
    await remoteDataSource.updateTask(taskModelFromDomain(task));
    await taskAssigneesRepository.deleteTaskAssignees(task.id);

    final taskAssignees = task.assignees
        .map((assignee) => TaskAssignee(
              taskId: task.id,
              memberId: assignee.id,
            ))
        .toList();

    if (taskAssignees.isNotEmpty) {
      await taskAssigneesRepository.addTaskAssignees(taskAssignees);
    }
  }

  TaskModel taskModelFromDomain(Task task) => TaskModel.fromDomain(task);
  
  @override
  Future<void> createTask(Task task) async {
    final insertedTaskId = await remoteDataSource.addTask(taskModelFromDomain(task));

    if (insertedTaskId == null) {
      throw Exception('Не удалось создать задачу в Supabase');
    }

    final taskAssignees = task.assignees
        .map((assignee) => TaskAssignee(
              taskId: insertedTaskId.toString(),
              memberId: assignee.id,
            ))
        .toList();

    if (taskAssignees.isNotEmpty) {
      await taskAssigneesRepository.addTaskAssignees(taskAssignees);
    }
  }
}
