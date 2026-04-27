import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_task_state.freezed.dart';

enum CreateTaskStatus { initial, loading, success, error }

@freezed
abstract class CreateTaskState with _$CreateTaskState {
  const factory CreateTaskState({
    @Default(CreateTaskStatus.initial) CreateTaskStatus status,
    @Default('') String? title,
    @Default('') String? description,
    String? familyId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? dueDate,
    @Default(false) bool completed,
    @Default(null) int? assigneeId,
    @Default(3) int priority,
    String? errorMessage
    
  }) = _CreateTaskState;
  
   const CreateTaskState._();
  
  bool get canSubmit => title!.trim().isNotEmpty && status != CreateTaskStatus.loading;
}