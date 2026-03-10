
import 'package:family_tracker/model/list.dart';
import 'package:family_tracker/pages/tab/list/list_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_tracker/features/lists/list_provider.dart';
import 'package:family_tracker/features/lists/list_repository_provider.dart';

class MyListItem extends ConsumerWidget {
  final Lists myList;

  const MyListItem({super.key, required this.myList});

  // Future<void> _deleteTask(WidgetRef ref) async {
  //   final repo = ref.read(taskRepositoryProvider);
  //   await repo.deleteTask(task.id);
  //   ref.invalidate(tasksProvider);
  // }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Удалить Список?"),
        content: const Text("Это действие нельзя отменить."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Удалить"),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        final repo = ref.read(listRepositoryProvider);
        await repo.deleteList(myList.id);
        ref.invalidate(listsProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(myList.title),
      onTap: () async {
        final changed = await showDialog<bool>(
          context: context,
          builder: (_) => ListDialog(
            myList: myList,
            familyId: myList.familyId,
          ),
        );
        if (changed == true) {
          ref.invalidate(listsProvider);
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirm(context, ref),
          ),
        ],
      ),
    );
  }
}
