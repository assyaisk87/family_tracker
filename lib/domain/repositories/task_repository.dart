import '../entities/family_user.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<Task?> getTaskById(String id);
  Future<void> addTask(Task task);
  Future<void> toggleTaskDone(String taskId);
  Future<List<FamilyUser>> getParticipants();
}
