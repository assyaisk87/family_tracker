import 'package:flutter/material.dart';

import '../../domain/entities/family_user.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../locator.dart';

class TaskEditScreen extends StatefulWidget {
  final Task task;
  final bool canEdit;

  const TaskEditScreen({super.key, required this.task, required this.canEdit});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskRepository = locator<TaskRepository>();

  List<FamilyUser> _availableAssignees = [];
  List<FamilyUser> _selectedAssignees = [];
  DateTime? _dueDate;
  bool _highPriority = false;
  bool _isSaving = false;
  bool _isLoadingParticipants = true;

  bool get _canEdit => widget.canEdit;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
    _descriptionController.text = widget.task.description ?? '';
    _dueDate = widget.task.dueDate;
    _highPriority = widget.task.priority;
    _selectedAssignees = List.from(widget.task.assignees);
    _loadParticipants();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipants() async {
    try {
      final participants = await _taskRepository.getParticipants();
      if (!mounted) return;
      setState(() {
        _availableAssignees = participants;
        _isLoadingParticipants = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _availableAssignees = [];
        _isLoadingParticipants = false;
      });
    }
  }

  void _toggleAssignee(FamilyUser assignee) {
    if (!_canEdit) return;
    setState(() {
      if (_selectedAssignees.any((item) => item.id == assignee.id)) {
        _selectedAssignees.removeWhere((item) => item.id == assignee.id);
      } else {
        _selectedAssignees.add(assignee);
      }
    });
  }

  Future<void> _saveTask() async {
    if (!_canEdit) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Название задачи не может быть пустым')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedTask = widget.task.copyWith(
      title: title,
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      priority: _highPriority,
      assignees: List.from(_selectedAssignees),
    );

    try {
      await _taskRepository.updateTask(updatedTask);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Задача успешно сохранена')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить задачу: $e')),
      );
    }
  }

  Future<void> _pickDueDate() async {
    if (!_canEdit) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.canEdit ? 'Редактировать задачу' : 'Просмотр задачи'),
      ),
      body: _isLoadingParticipants
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                      enabled: _canEdit,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      enabled: _canEdit,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Высокий приоритет'),
                      value: _highPriority,
                      onChanged: _canEdit
                          ? (value) {
                              setState(() => _highPriority = value);
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Исполнители:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableAssignees.map((assignee) {
                        final isSelected = _selectedAssignees.any((item) => item.id == assignee.id);
                        return FilterChip(
                          label: Text(assignee.displayName),
                          selected: isSelected,
                          onSelected: !_canEdit
                              ? null
                              : (_) => _toggleAssignee(assignee),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Срок до:'),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _canEdit ? _pickDueDate : null,
                          child: Text(
                            _dueDate != null
                                ? '${_dueDate!.day}.${_dueDate!.month}.${_dueDate!.year}'
                                : 'Не задано',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_canEdit)
                      FilledButton(
                        onPressed: _isSaving ? null : _saveTask,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Сохранить'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
