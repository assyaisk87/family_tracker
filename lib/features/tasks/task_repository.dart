import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../model/task.dart';

class TaskRepository {
  final SupabaseClient client;

  TaskRepository(this.client);

  // 🔹 Получить задачи
  Future<List<Task>> fetchTasks(int familyId) async {
    final response = await client
        .from('tasks')
        .select('''
          *,
          task_assignees (
            member_id
          )
        ''')
        .eq('family_id', familyId)
        .order('due_date');

    return (response as List).map((e) => Task.fromJson(e)).toList();
  }

  // 🔹 Создать задачу
  Future<void> createTask({
    required int familyId,
    required int createdBy,
    required String title,
    required String? description,
    required DateTime? dueDate,
    required List<int> memberIds,
  }) async {
    final task = await client
        .from('tasks')
        .insert({
          'family_id': familyId,
          'title': title,
          'description': description,
          'created_by': createdBy,
          'due_date': dueDate?.toIso8601String(),
          'completed': false,
        })
        .select()
        .single();

    final taskId = task['id'] as int;

    if (memberIds.isNotEmpty) {
      final assignees = memberIds
          .map((id) => {'task_id': taskId, 'member_id': id})
          .toList();

      await client.from('task_assignees').insert(assignees);
    }
  }

  // 🔹 Обновить задачу
  Future<void> updateTask({
    required int taskId,
    required String title,
    required String? description,
    required DateTime? dueDate,
    required List<int> memberIds,
  }) async {
    // 1️⃣ Обновляем основную таблицу
    await client
        .from('tasks')
        .update({
          'title': title,
          'description': description,
          'due_date': dueDate?.toIso8601String(),
        })
        .eq('id', taskId);

    // 2️⃣ Удаляем старые назначения
    await client.from('task_assignees').delete().eq('task_id', taskId);

    // 3️⃣ Добавляем новые назначения
    if (memberIds.isNotEmpty) {
      final assignees = memberIds
          .map((id) => {'task_id': taskId, 'member_id': id})
          .toList();

      await client.from('task_assignees').insert(assignees);
    }
  }

  // 🔹 Удалить задачу
  Future<void> deleteTask(int taskId) async {
    await client.from('tasks').delete().eq('id', taskId);
  }

  // 🔹 Переключить выполнение
  Future<void> toggleTask(int taskId, bool completed) async {
    await client
        .from('tasks')
        .update({'completed': completed})
        .eq('id', taskId);
  }
}
