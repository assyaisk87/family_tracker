import 'package:family_tracker/domain/entities/task.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';
import 'package:family_tracker/presentation/cubit/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repository;

  TaskCubit(this._repository) : super(const TaskState());

  Future<void> loadTasks() async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));

    try {
      final tasks = await _repository.getTasks();
      emit(state.copyWith(
        status: TaskStatus.loaded,
        tasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: 'Ошибка загрузки задач: $e',
      ));
    }
  }

  Future<void> addTask(Task task) async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));

    try {
      await _repository.addTask(task);
      await loadTasks(); // Перезагрузить список задач
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: 'Ошибка добавления задачи: $e',
      ));
    }
  }

  Future<void> toggleTaskDone(String taskId) async {
    try {
      await _repository.toggleTaskDone(taskId);
      await loadTasks(); // Перезагрузить список задач
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: 'Ошибка обновления задачи: $e',
      ));
    }
  }

  Future<void> getTaskById(String id) async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));

    try {
      final task = await _repository.getTaskById(id);
      emit(state.copyWith(
        status: TaskStatus.loaded,
        selectedTask: task,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: 'Ошибка загрузки задачи: $e',
      ));
    }
  }
}