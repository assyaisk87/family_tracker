import 'package:family_tracker/domain/entities/task.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_state.freezed.dart';

enum TaskStatus { initial, loading, loaded, error }

@freezed
abstract class TaskState with _$TaskState {
  const factory TaskState({
    @Default(TaskStatus.initial) TaskStatus status,
    @Default([]) List<Task> tasks,
    Task? selectedTask,
    String? errorMessage,
  }) = _TaskState;
}