import 'package:family_tracker/core/theme/app_colors.dart';
import 'package:family_tracker/features/family/family_map_provider.dart';
import 'package:family_tracker/features/session/session_provider.dart';
import 'package:family_tracker/features/tasks/filter/filtered_tasks_provider.dart';
import 'package:family_tracker/pages/tab/list/list_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_dialog.dart';
import 'task_filter_bar.dart';
import 'task_list_item.dart';

class TaskTab extends ConsumerWidget {
  const TaskTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final sessionAsync = ref.watch(sessionProvider).value;

    if (sessionAsync == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final session = sessionAsync;
    final memberId = session.member!.id;
    final familyId = session.member!.familyId;
    final mySessionMemberId = session.myMemberId;
    final membersMap = ref.watch(familyMembersMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white,),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
       drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(decoration: BoxDecoration(color: AppColors.primary, ),child: Text('Меню',style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight(600)),),),
              ListTile(
                leading: const Icon(Icons.list,),
                title: const Text('Списки'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListTab()),
                  );
                },
              ),
            ],
          ),
        ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text("Нет задач"));
          }

          return Column(
            children: [
              // Фильтр
              const TaskFilterBar(),
              // Список задач
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final creator = membersMap[task.createdBy];

                    return TaskListItem(
                      task: task,
                      creator: creator,
                      membersMap: membersMap,
                      mySessionMemberId: mySessionMemberId!,
                      memberId: memberId,
                      familyId: familyId,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Ошибка: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => TaskDialog(
              memberId: memberId,
              familyId: familyId,
              mySessionMemberId: mySessionMemberId!,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
