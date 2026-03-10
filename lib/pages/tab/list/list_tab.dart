import 'package:family_tracker/features/lists/list_provider.dart';
import 'package:family_tracker/features/session/session_provider.dart';
import 'package:family_tracker/pages/tab/list/list_dialog.dart';
import 'package:family_tracker/pages/tab/list/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListTab extends ConsumerWidget {
  const ListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);
    final sessionAsync = ref.watch(sessionProvider).value;

    if (sessionAsync == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final session = sessionAsync;
    final familyId = session.member!.familyId;

    return Scaffold(
      appBar: AppBar(title: const Text('Списки'),
      leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),),
      
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return const Center(child: Text("Список пуст"));
          }
          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final myList = lists[index];
              return MyListItem(myList: myList);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Ошибка: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await showDialog<bool>(
            context: context,
            builder: (_) => ListDialog(
              familyId: familyId,              
            ),
          );
          if (changed == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.invalidate(listsProvider);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
