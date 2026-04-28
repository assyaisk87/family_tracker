import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';
import 'package:family_tracker/locator.dart';
import 'package:family_tracker/presentation/cubit/create_task_cubit.dart';
import 'package:family_tracker/presentation/cubit/task_cubit.dart';
import 'package:family_tracker/presentation/cubit/task_state.dart';
import 'package:family_tracker/presentation/screens/create_task_screen.dart';
import 'package:family_tracker/presentation/screens/edit_task_screen.dart';
import 'package:family_tracker/presentation/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => CreateTaskCubit(
                      locator<TaskRepository>(),
                      locator<AuthRepository>(),
                    ),
                    child: CreateTaskScreen(),
                  ),
                ),
              ).then((_) {
                if (context.mounted) {
                  context.read<TaskCubit>().loadTasks();
                }
              });
            },
            icon: Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.status == TaskStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.tasks.isEmpty) {
            return Text('Список пуст');
          }

          return Column(
            children: [
              // Фильтры и сортировка
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<TaskSortBy>(
                        value: state.sortBy,
                        icon: const Icon(Icons.sort),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<TaskCubit>().updateSortBy(value);
                          }
                        },
                        items: TaskSortBy.values.map((sortBy) {
                          return DropdownMenuItem(
                            value: sortBy,
                            child: Text(_getSortByLabel(sortBy)),
                          );
                        }).toList(),
                        hint: Text('Сортировка'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<TaskFilter>(
                        value: state.filter,
                        icon: const Icon(Icons.filter_alt),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<TaskCubit>().updateFilter(value);
                          }
                        },
                        items: TaskFilter.values.map((filter) {
                          return DropdownMenuItem(
                            value: filter,
                            child: Text(_getFilterLabel(filter)),
                          );
                        }).toList(),
                        hint: Text('Фильтр'),
                      ),
                    ),
                  ],
                ),
              ),
              // Список задач
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final task = state.filteredTasks[index];
                    final cubit = context.read<TaskCubit>();
                    final canDelete = cubit.canDeleteTask(task);
                    final canEdit = cubit.canEditTask(task);
                    final taskWidget = TaskCard(
                      task: task,
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskEditScreen(
                              task: task,
                              canEdit: canEdit,
                            ),
                          ),
                        );
                        if (updated == true && context.mounted) {
                          context.read<TaskCubit>().loadTasks();
                        }
                      },
                      onToggle: () =>
                          context.read<TaskCubit>().toggleTaskDone(task.id),
                    );

                    if (!canDelete) {
                      return taskWidget;
                    }

                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Подтверждение'),
                              content: const Text(
                                'Вы точно хотите удалить задачу?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Удалить'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete != true) {
                          return false;
                        }

                        try {
                          await cubit.deleteTask(task.id);
                          return true;
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Не удалось удалить задачу: $e'),
                              ),
                            );
                          }
                          return false;
                        }
                      },
                      child: taskWidget,
                    );
                  },
                  separatorBuilder: (_, _) => Divider(height: 1),
                  itemCount: state.filteredTasks.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getSortByLabel(TaskSortBy sortBy) {
    switch (sortBy) {
      case TaskSortBy.createdAt:
        return 'По дате создания';
      case TaskSortBy.dueDate:
        return 'По сроку';
      case TaskSortBy.priority:
        return 'По приоритету';
      case TaskSortBy.completed:
        return 'По статусу';
    }
  }

  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'Все';
      case TaskFilter.completed:
        return 'Завершенные';
      case TaskFilter.pending:
        return 'Незавершенные';
      case TaskFilter.highPriority:
        return 'Высокий приоритет';
    }
  }
}
