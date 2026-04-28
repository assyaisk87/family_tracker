import 'package:family_tracker/presentation/cubit/create_task_cubit.dart';
import 'package:family_tracker/presentation/cubit/create_task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

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
        title: const Text('Создать задачу'),
      ),
      body: BlocConsumer<CreateTaskCubit, CreateTaskState>(
        listener: (context, state) {
          if (state.status == CreateTaskStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Задача создана!')),
            );
            Navigator.of(context).pop();
          } else if (state.status == CreateTaskStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Ошибка создания задачи'),
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
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Название задачи *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: context.read<CreateTaskCubit>().titleChanged,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: context.read<CreateTaskCubit>().descriptionChanged,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Высокий приоритет'),
                    value: state.highPriority,
                    onChanged: isLoading ? null : context.read<CreateTaskCubit>().highPriorityChanged,
                  ),
                  const SizedBox(height: 16),
                  const Text('Исполнители:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: state.availableAssignees.map((assignee) {
                      final isSelected = state.selectedAssignees.contains(assignee);
                      return FilterChip(
                        label: Text(assignee.displayName),
                        selected: isSelected,
                        onSelected: isLoading
                            ? null
                            : (selected) => context.read<CreateTaskCubit>().toggleAssignee(assignee),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Срок выполнения:'),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null && mounted) {
                                  context.read<CreateTaskCubit>().dueDateChanged(picked);
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
                  FilledButton(
                    onPressed: isLoading || !state.canSubmit
                        ? null
                        : () => context.read<CreateTaskCubit>().submit(),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Создать задачу'),
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