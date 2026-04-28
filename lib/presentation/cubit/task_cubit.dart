import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/entities/task.dart';
import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/family_users_repository.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';
import 'package:family_tracker/presentation/cubit/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repository;
  final AuthRepository _authRepository;
  final FamilyUsersRepository _familyUsersRepository;
  String? _currentUserId;
  bool _currentUserIsParent = false;

  TaskCubit(
    this._repository,
    this._authRepository,
    this._familyUsersRepository,
  ) : super(const TaskState());

  Future<void> loadTasks() async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));

    try {
      await _loadCurrentUserContext();
      final tasks = await _repository.getTasks();
      final filteredTasks = _applyFiltersAndSorting(tasks);
      emit(state.copyWith(
        status: TaskStatus.loaded,
        tasks: tasks,
        filteredTasks: filteredTasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: 'Ошибка загрузки задач: $e',
      ));
    }
  }

  Future<void> _loadCurrentUserContext() async {
    try {
      final authUser = await _authRepository.getCurrentUserWithFamily();
      if (authUser == null || authUser.familyId == null) {
        _currentUserId = null;
        _currentUserIsParent = false;
        return;
      }

      final familyId = int.tryParse(authUser.familyId!);
      if (familyId == null) {
        _currentUserId = null;
        _currentUserIsParent = false;
        return;
      }

      final members = await _familyUsersRepository.getFamilyUsers(familyId);
      FamilyUser? currentMember;
      try {
        currentMember = members.firstWhere(
          (member) => member.id == authUser.id || member.userId == authUser.id,
        );
      } catch (_) {
        currentMember = null;
      }

      _currentUserId = currentMember?.id;
      _currentUserIsParent = currentMember?.role ?? false;
    } catch (_) {
      _currentUserId = null;
      _currentUserIsParent = false;
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

  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      await loadTasks();
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: 'Ошибка удаления задачи: $e',
      ));
      rethrow;
    }
  }

  bool canDeleteTask(Task task) {
    if (_currentUserIsParent) return true;
    if (_currentUserId == null) return false;
    return task.createdBy == _currentUserId;
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

  void updateSortBy(TaskSortBy sortBy) {
    final filteredTasks = _applyFiltersAndSorting(state.tasks, sortBy: sortBy);
    emit(state.copyWith(
      sortBy: sortBy,
      filteredTasks: filteredTasks,
    ));
  }

  void updateFilter(TaskFilter filter) {
    final filteredTasks = _applyFiltersAndSorting(state.tasks, filter: filter);
    emit(state.copyWith(
      filter: filter,
      filteredTasks: filteredTasks,
    ));
  }

  List<Task> _applyFiltersAndSorting(
    List<Task> tasks, {
    TaskSortBy? sortBy,
    TaskFilter? filter,
  }) {
    sortBy ??= state.sortBy;
    filter ??= state.filter;

    // Применить фильтры
    var filteredTasks = tasks.where((task) {
      // Фильтр по статусу
      switch (filter) {
        case TaskFilter.completed:
          if (!task.completed) return false;
          break;
        case TaskFilter.pending:
          if (task.completed) return false;
          break;
        case TaskFilter.highPriority:
          if (!task.priority) return false;
          break;
        case TaskFilter.all:
        default:
          break;
      }     

      return true;
    }).toList();

    // Применить сортировку
    filteredTasks.sort((a, b) {
      switch (sortBy) {
        case TaskSortBy.createdAt:
          return b.createdAt.compareTo(a.createdAt); // Новые сначала
        case TaskSortBy.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case TaskSortBy.priority:
          if (a.priority == b.priority) return 0;
          return a.priority ? -1 : 1; // Высокий приоритет сначала
        case TaskSortBy.completed:
          if (a.completed == b.completed) return 0;
          return a.completed ? 1 : -1; // Незавершенные сначала
        default:
          return 0;
      }
    });

    return filteredTasks;
  }
}