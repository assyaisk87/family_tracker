import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/presentation/cubit/create_task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tracker/domain/entities/task.dart';
import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';

class CreateTaskCubit extends Cubit<CreateTaskState> {
  final TaskRepository _repository;
  final AuthRepository _authRepository;

   CreateTaskCubit(this._repository, this._authRepository)
    : super(const CreateTaskState());

  void contentChanged(String value) {
    emit(state.copyWith(title: value));
  }
  
  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: CreateTaskStatus.loading));
    final authUser = _authRepository.currentUser;

    final newTask = Task(
       id: DateTime.now().millisecond.toString(),
      // content: state.content.trim(),
      // authorId: authUser!.id,
      // createdAt: DateTime.now().toIso8601String(),
      // likes: 0,
      // imageUrl: state.imageUrl,
      title: state.title!.trim(),
      description: state.description!.trim(),
      familyId : state.familyId.toString(),
      createdBy: authUser!.id,
      createdAt: DateTime.now(),
      dueDate: state.dueDate,
      completed : false,
      assignees: List<FamilyUser>.empty(),
      priority:state.priority,
    );

    try {
      await _repository.createTask(newTask);
      emit(state.copyWith(status: CreateTaskStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateTaskStatus.error,
          errorMessage: 'Ошибка создания задачи',
        ),
      );
    }
  }
}