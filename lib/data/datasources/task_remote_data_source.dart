import '../models/family_user_model.dart';
import '../models/task_model.dart';
import 'supabase_service.dart';

class TaskRemoteDataSource {
  final SupabaseService supabaseService = SupabaseService.instance;

  Future<List<TaskModel>> fetchTasks() async {
    try {
      // Попытка загрузить из Supabase
      if (supabaseService.initialized) {
        final response = await supabaseService.client
            .from('tasks')
            .select('''
              *,
              task_assignees (
                family_members (
                  id,
                  family_id,
                  user_id,
                  role,
                  display_name,
                  avatar_url
                )
              )
            ''')
            .order('created_at', ascending: false);

        return (response as List)
            .map((task) => _taskModelFromJson(task))
            .toList();
      }
    } catch (e) {
      // Fallback на локальные данные
      print('Ошибка загрузки задач из Supabase: $e');
    }

    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable([]);
  }

  Future<TaskModel?> fetchTaskById(String id) async {
    try {
      if (supabaseService.initialized) {
        final response = await supabaseService.client
            .from('tasks')
            .select('''
              *,
              task_assignees (
                family_members (
                  id,
                  family_id,
                  user_id,
                  role,
                  display_name,
                  avatar_url
                )
              )
            ''')
            .eq('id', id)
            .single();

        return _taskModelFromJson(response);
      }
    } catch (e) {
      print('Ошибка загрузки задачи из Supabase: $e');
    }

    await Future.delayed(const Duration(milliseconds: 120));
    return null;
  }

  Future<void> addTask(TaskModel task) async {
    try {
      if (supabaseService.initialized) {
        final taskData = _taskModelToJson(task);
        final insertedTask = await supabaseService.client
            .from('tasks')
            .insert(taskData)
            .select()
            .single();

        // Добавляем assignees
        for (final assignee in task.assignees) {
          await supabaseService.client
              .from('task_assignees')
              .insert({
                'task_id': task.id,
                'assignee_id': assignee.id,
              });
        }
        return;
      }
    } catch (e) {
      print('Ошибка добавления задачи в Supabase: $e');
    }

  
  }

  Future<void> toggleTaskDone(String taskId) async {
    try {
      if (supabaseService.initialized) {
        final currentTask = await supabaseService.client
            .from('tasks')
            .select('completed')
            .eq('id', taskId)
            .single();

        final newCompleted = !currentTask['completed'];
        await supabaseService.client
            .from('tasks')
            .update({'completed': newCompleted})
            .eq('id', taskId);
        return;
      }
    } catch (e) {
      print('Ошибка обновления задачи в Supabase: $e');
    }

    await Future.delayed(const Duration(milliseconds: 150));
   
  }

  Future<List<FamilyUserModel>> fetchParticipants() async {
    try {
      if (supabaseService.initialized) {
        final response = await supabaseService.client
            .from('family_members')
            .select();

        return (response as List)
            .map((user) => FamilyUserModel(
              id: user['id'],
              familyId: user['family_id'],
              userId: user['user_id'],
              role: user['role'] ?? false,
              displayName: user['display_name'] ?? 'Unknown',
              avatarUrl: user['avatar_url'] ?? '',
            ))
            .toList();
      }
    } catch (e) {
      print('Ошибка загрузки участников из Supabase: $e');
    }
    return [];
  }

  // Утилиты для конвертации JSON
  TaskModel _taskModelFromJson(Map<String, dynamic> json) {
    final assignees = (json['task_assignees'] as List<dynamic>?)
        ?.map((assignee) => FamilyUserModel(
              id: assignee['family_members']['id'],
              familyId: assignee['family_members']['family_id'],
              userId: assignee['family_members']['user_id'],
              role: assignee['family_members']['role'] ?? false,
              displayName: assignee['family_members']['display_name'] ?? 'Unknown',
              avatarUrl: assignee['family_members']['avatar_url'] ?? '',
            ))
        .toList() ?? [];

    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      familyId: json['family_id'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completed: json['completed'] ?? false,
      assignees: assignees,
      priority: json['priority'] ?? 0,
    );
  }

  Map<String, dynamic> _taskModelToJson(TaskModel task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'family_id': task.familyId,
      'created_by': task.createdBy,
      'created_at': task.createdAt.toIso8601String(),
      'due_date': task.dueDate?.toIso8601String(),
      'completed': task.completed,
      'priority': task.priority,
    };
  }
}
