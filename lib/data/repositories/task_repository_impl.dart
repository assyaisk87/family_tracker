import '../../domain/entities/family_user.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

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

  TaskModel taskModelFromDomain(Task task) => TaskModel.fromDomain(task);
  
  @override
  Future<void> createTask(Task task) {
    // TODO: implement createTask
    throw UnimplementedError();
  }
}
