
import 'package:family_tracker/features/lists/list_repository_provider.dart';
import 'package:family_tracker/model/list.dart';
import 'package:family_tracker/model/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListDialog extends ConsumerStatefulWidget {
  final Lists? myList;
  final int familyId;  

  const ListDialog({
    super.key,
    this.myList,
    required this.familyId,
  });

  @override
  ConsumerState<ListDialog> createState() => _ListDialogState();
}

class _ListDialogState extends ConsumerState<ListDialog> {
  late final TextEditingController _titleController;
  final List<TextEditingController> _itemControllers = [];
  bool _itemsLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.myList?.title ?? '');

    if (widget.myList != null) {
      _loadItems();
    } else {
      _addItem();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _itemsLoading = true;
    });
    final repo = ref.read(listRepositoryProvider);
    final items = await repo.fetchListItems(widget.myList!.id);
    setState(() {
      _itemControllers.clear();
      for (var item in items) {
        _itemControllers.add(TextEditingController(text: item.title));
      }
      if (_itemControllers.isEmpty) _addItem();
      _itemsLoading = false;
    });
  }

  void _addItem() {
    setState(() {
      _itemControllers.add(TextEditingController());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllers[index].dispose();
      _itemControllers.removeAt(index);
    });
  }

  Future<void> _onSave() async {
    if (_titleController.text.isEmpty) {
      return;
    }

    final repo = ref.read(listRepositoryProvider);

    if (widget.myList == null) {
      final newId = await repo.createList(
        familyId: widget.familyId,
        title: _titleController.text,
      );
      // insert items if any
      final items = _itemControllers
          .where((c) => c.text.trim().isNotEmpty)
          .map((c) => ListItem(
                id: 0,
                taskId: null,
                title: c.text.trim(),
                completed: false,
                orderIndex: null,
                comment: null,
              ))
          .toList();
      if (items.isNotEmpty) {
        await repo.upsertListItems(newId, items);
      }
    } else {
      await repo.updateList(
        listId: widget.myList!.id,
        title: _titleController.text,
      );
      final items = _itemControllers
          .where((c) => c.text.trim().isNotEmpty)
          .map((c) => ListItem(
                id: 0,
                taskId: null,
                title: c.text.trim(),
                completed: false,
                orderIndex: null,
                comment: null,
              ))
          .toList();
      await repo.upsertListItems(widget.myList!.id, items);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text(
        widget.myList == null ? "Создать список" : "Редактировать список",
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
            const Text('Элементы списка'),
            const SizedBox(height: 8),
            if (_itemsLoading)
              const Center(child: CircularProgressIndicator()),
            if (!_itemsLoading) ..._itemControllers.asMap().entries.map((entry) {
              final idx = entry.key;
              final ctrl = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: InputDecoration(
                          labelText: 'Пункт ${idx + 1}'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeItem(idx),
                  ),
                ],
              );
            }),
            if (!_itemsLoading)
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Добавить элемент'),
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
