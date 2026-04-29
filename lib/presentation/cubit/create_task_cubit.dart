import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/presentation/cubit/create_task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tracker/domain/entities/task.dart';
import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';

class CreateTaskCubit extends Cubit<CreateTaskState> {
  final TaskRepository _taskRepository;
  final AuthRepository _authRepository;

   CreateTaskCubit(this._taskRepository, this._authRepository)
    : super(const CreateTaskState()) {
     _loadInitialData();
   }

  Future<void> _loadInitialData() async {
    try {
      // Получаем текущего пользователя с familyId
      final authUser = await _authRepository.getCurrentUserWithFamily();
      final familyId = authUser?.familyId;

      // Загружаем участников семьи
      final assignees = familyId != null ? await _taskRepository.getParticipants() : <FamilyUser>[];

      emit(state.copyWith(
        familyId: familyId,
        availableAssignees: assignees,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreateTaskStatus.error,
        errorMessage: 'Ошибка загрузки данных: $e',
      ));
    }
  }

  void titleChanged(String value) {
    emit(state.copyWith(title: value));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  void highPriorityChanged(bool value) {
    emit(state.copyWith(highPriority: value));
  }

  void dueDateChanged(DateTime? value) {
    emit(state.copyWith(dueDate: value));
  }

  void toggleAssignee(FamilyUser assignee) {
    final selectedAssignees = List<FamilyUser>.from(state.selectedAssignees);
    if (selectedAssignees.contains(assignee)) {
      selectedAssignees.remove(assignee);
    } else {
      selectedAssignees.add(assignee);
    }
    emit(state.copyWith(selectedAssignees: selectedAssignees));
  }

  Future<void> submit({Task? task}) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: CreateTaskStatus.loading));
    final authUser = await _authRepository.getCurrentUserWithFamily();

    final updatedTask;
    if (task != null) {
      updatedTask = task?.copyWith(
        title: state.title,
        description: state.description,
        dueDate: state.dueDate,
        priority: state.highPriority,
        assignees: state.selectedAssignees,
      );
    } else {
      updatedTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: state.title!.trim(),
        description: state.description?.trim() ?? '',
        familyId: state.familyId ?? authUser?.familyId ?? 'default_family',
        createdBy: authUser!.id,
        createdAt: DateTime.now(),
        dueDate: state.dueDate,
        completed: false,
        assignees: state.selectedAssignees,
        priority: state.highPriority,
      );
    }
    try {
      if (task != null) {
        await _taskRepository.updateTask(updatedTask!);
      } else {
        await _taskRepository.createTask(updatedTask);
      }

      emit(state.copyWith(status: CreateTaskStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateTaskStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> initEdit(Task task) async {
    final users = await _taskRepository.getParticipants();

    emit(
      state.copyWith(
        title: task.title,
        description: task.description ?? '',
        dueDate: task.dueDate,
        highPriority: task.priority,
        selectedAssignees: task.assignees,
        availableAssignees: users,
      ),
    );
  }
}