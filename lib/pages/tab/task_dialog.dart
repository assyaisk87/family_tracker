import 'package:family_tracker/features/family/family_members_provider.dart';
import 'package:family_tracker/features/tasks/task_repository_provider.dart';
import 'package:family_tracker/features/tasks/tasks_provider.dart';
import 'package:family_tracker/model/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskDialog extends ConsumerStatefulWidget {
  final Task? task;
  final int memberId;
  final int familyId;
  final int mySessionMemberId;

  const TaskDialog({
    super.key,
    this.task,
    required this.memberId,
    required this.familyId,
    required this.mySessionMemberId,
  });

  @override
  ConsumerState<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<TaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;
  late List<int> _assignedTo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    // Создаём новую копию списка, чтобы избежать дублирования
    _assignedTo = List.from(widget.task?.assignees ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_assignedTo.isEmpty || _titleController.text.isEmpty) {
      return;
    }

    final repo = ref.read(taskRepositoryProvider);

    if (widget.task == null) {
      await repo.createTask(
        familyId: widget.familyId,
        createdBy: widget.memberId,
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate,
        memberIds: _assignedTo,
      );
    } else {
      await repo.updateTask(
        taskId: widget.task!.id,
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate,
        memberIds: _assignedTo,
      );
    }

    ref.invalidate(tasksProvider);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showAssigneeSelection(List<dynamic> members) {
    List<int> tempAssigned = List.from(_assignedTo);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Выберите исполнителей'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempAssigned = List.from(members.map((m) => m.id));
                        });
                      },
                      child: const Text('Выбрать всех'),
                    ),
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempAssigned.clear();
                        });
                      },
                      child: const Text('Отменить всех'),
                    ),
                  ],
                ),
                const Divider(),
                ...members.map((member) {
                  return CheckboxListTile(
                    value: tempAssigned.contains(member.id),
                    onChanged: (selected) {
                      setDialogState(() {
                        if (selected == true) {
                          tempAssigned.add(member.id);
                        } else {
                          tempAssigned.remove(member.id);
                        }
                      });
                    },
                    title: Text(member.displayName ?? ''),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _assignedTo = tempAssigned;
                });
                Navigator.pop(context);
              },
              child: const Text('Готово'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(familyMembersProvider);

    return AlertDialog(
      title: Text(
        widget.task == null ? "Создать задачу" : "Редактировать задачу",
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Название:"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Описание:"),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Срок до: ${_selectedDate.toLocal().toString().split(' ')[0]}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            membersAsync.when(
              data: (members) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Исполнители:'),
                  subtitle: _assignedTo.isEmpty
                      ? const Text('Не выбраны')
                      : Text(
                          members
                              .where((m) => _assignedTo.contains(m.id))
                              .map((m) => m.displayName ?? '')
                              .join(', '),
                        ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showAssigneeSelection(members),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const Text("Ошибка загрузки"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Отмена"),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text("Сохранить"),
        ),
      ],
    );
  }
}
