import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';
import 'package:family_tracker/locator.dart';
import 'package:family_tracker/presentation/cubit/create_task_cubit.dart';
import 'package:family_tracker/presentation/cubit/task_cubit.dart';
import 'package:family_tracker/presentation/cubit/task_state.dart';
import 'package:family_tracker/presentation/screens/create_task_screen.dart';
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
                    return TaskCard(
                      task: task,
                      onTap: () => {}, // TODO: Навигация к деталям задачи
                      onToggle: () =>
                          context.read<TaskCubit>().toggleTaskDone(task.id),
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
