import '../models/task_assignee_model.dart';
import 'supabase_service.dart';

class TaskAssigneesRemoteDataSource {
  final SupabaseService supabaseService = SupabaseService.instance;

  Future<void> addTaskAssignees(List<TaskAssigneeModel> assignees) async {
    if (!supabaseService.initialized || assignees.isEmpty) {
      return;
    }

    final rows = assignees.map((assignee) => assignee.toJson()).toList();

    try {
      await supabaseService.client
          .from('task_assignees')
          .insert(rows);
    } catch (e) {
      print('Ошибка добавления task_assignees: $e');
      rethrow;
    }
  }

  Future<List<TaskAssigneeModel>> fetchTaskAssignees(String taskId) async {
    if (!supabaseService.initialized) {
      return [];
    }

    try {
      final response = await supabaseService.client
          .from('task_assignees')
          .select()
          .eq('task_id', int.parse(taskId));

      return (response as List)
          .map((item) => TaskAssigneeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Ошибка загрузки task_assignees: $e');
      return [];
    }
  }

  Future<void> deleteTaskAssignees(String taskId) async {
    if (!supabaseService.initialized) {
      return;
    }

    try {
      await supabaseService.client
          .from('task_assignees')
          .delete()
          .eq('task_id', int.parse(taskId));
    } catch (e) {
      print('Ошибка удаления task_assignees: $e');
      rethrow;
    }
  }
}
