import 'package:family_tracker/features/family/family_members_provider.dart';
import 'package:family_tracker/features/family/family_repository_provider.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamilyMembersSection extends ConsumerWidget {
  final int familyId;
  final String currentUserId;
  final bool role;

  const FamilyMembersSection({super.key, 
    required this.familyId,
    required this.currentUserId,
    required this.role,
  });

  void _showEditMemberDialog(
    BuildContext context,
    FamilyMember member,
    WidgetRef ref,
  ) {
    final nameController = TextEditingController(
      text: member.displayName ?? '',
    );
    final repo = ref.read(familyRepositoryProvider);

    showDialog(
      context: context,
      builder: (_) {
        bool roleIsParent = member.role;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Редактировать участника"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Имя"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<bool>(
                    value: roleIsParent,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Родитель")),
                      DropdownMenuItem(value: false, child: Text("Ребёнок")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          roleIsParent = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Отмена"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedMember = FamilyMember(
                      id: member.id,
                      familyId: member.familyId,
                      userId: member.userId,
                      displayName: nameController.text,
                      role: roleIsParent,
                      avatarUrl: '',
                    );

                    await repo.updateMember(updatedMember);
                    ref.invalidate(familyMembersProvider);
                    Navigator.pop(context);
                  },
                  child: const Text("Сохранить"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(familyMembersProvider);

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Ошибка: $e'),
      data: (members) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Члены семьи",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...members.map(
              (member) => Card(
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: member.avatarUrl.isNotEmpty
                            ? NetworkImage(member.avatarUrl)
                            : null,
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          child: member.userId == currentUserId
                              ? const Icon(Icons.star, color: Colors.yellow)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  title: Text(member.displayName ?? "Без имени"),
                  subtitle: Text(member.role == true ? "Родитель" : "Ребёнок"),
                  trailing: role == true
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditMemberDialog(context, member, ref);
                          },
                        )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
