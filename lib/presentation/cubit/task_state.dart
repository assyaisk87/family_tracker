import 'package:family_tracker/domain/entities/task.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_state.freezed.dart';

enum TaskStatus { initial, loading, loaded, error }

enum TaskSortBy { createdAt, dueDate, priority, completed }

enum TaskFilter { all, completed, pending, highPriority }

@freezed
abstract class TaskState with _$TaskState {
  const factory TaskState({
    @Default(TaskStatus.initial) TaskStatus status,
    @Default([]) List<Task> tasks,
    @Default([]) List<Task> filteredTasks,
    Task? selectedTask,
    String? errorMessage,
    @Default(TaskSortBy.createdAt) TaskSortBy sortBy,
    @Default(TaskFilter.all) TaskFilter filter,
    String? assigneeFilter,
  }) = _TaskState;
}