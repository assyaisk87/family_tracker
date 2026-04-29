import 'package:family_tracker/data/repositories/task_repository_impl.dart';
import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/entities/task.dart';
import 'package:family_tracker/domain/repositories/task_repository.dart';
import 'package:family_tracker/locator.dart';
import 'package:family_tracker/presentation/cubit/create_task_cubit.dart';
import 'package:family_tracker/presentation/cubit/create_task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final bool canEdit;

  const TaskFormScreen({super.key, this.task, this.canEdit = false});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get isEdit => widget.task != null;
  bool get _canEdit => widget.canEdit;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<CreateTaskCubit>();

    if (isEdit) {
      final task = widget.task!;

      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';

      cubit.initEdit(task);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать задачу' : 'Создать задачу'),
      ),
      body: BlocConsumer<CreateTaskCubit, CreateTaskState>(
        listener: (context, state) {
          if (state.status == CreateTaskStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? 'Задача обновлена!' : 'Задача создана!'),
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state.status == CreateTaskStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Ошибка'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == CreateTaskStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Название
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Название задачи *',
                      border: OutlineInputBorder(),
                      enabled: _canEdit,
                    ),
                    onChanged: context.read<CreateTaskCubit>().titleChanged,
                  ),

                  const SizedBox(height: 16),

                  /// Описание
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                      enabled: _canEdit,
                    ),
                    maxLines: 3,
                    onChanged: context
                        .read<CreateTaskCubit>()
                        .descriptionChanged,
                  ),

                  const SizedBox(height: 16),

                  /// Приоритет
                  SwitchListTile(
                    title: const Text('Высокий приоритет'),
                    value: state.highPriority,
                    onChanged: isLoading || !_canEdit
                        ? null
                        : context.read<CreateTaskCubit>().highPriorityChanged,
                  ),

                  const SizedBox(height: 16),

                  /// Исполнители
                  const Text(
                    'Исполнители:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: state.availableAssignees.map((assignee) {
                      final isSelected = state.selectedAssignees .any((u) => u.id == assignee.id);
                      return FilterChip(
                        label: Text(assignee.displayName),
                        selected: isSelected,
                        onSelected: isLoading || !_canEdit
                            ? null
                            : (_) => context
                                  .read<CreateTaskCubit>()
                                  .toggleAssignee(assignee),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  /// Дата
                  Row(
                    children: [
                      const Text('Срок выполнения:'),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: isLoading || !_canEdit
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: state.dueDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );

                                if (picked != null && mounted) {
                                  context
                                      .read<CreateTaskCubit>()
                                      .dueDateChanged(picked);
                                }
                              },
                        child: Text(
                          state.dueDate != null
                              ? '${state.dueDate!.day}.${state.dueDate!.month}.${state.dueDate!.year}'
                              : 'Выбрать дату',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Кнопка
                  FilledButton(
                    onPressed: isLoading || !state.canSubmit || !_canEdit
                        ? null
                        : () => context.read<CreateTaskCubit>().submit(
                            task: widget.task,
                          ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Сохранить' : 'Создать задачу'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
