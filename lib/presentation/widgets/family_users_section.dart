import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:flutter/material.dart';

class FamilyMembersSection extends StatelessWidget {
  final int familyId;
  final String currentUserId;
  final bool role;
  final List<FamilyUser> members;

  const FamilyMembersSection({
    super.key,
    required this.familyId,
    required this.currentUserId,
    required this.role,
    required this.members,
  });

  void _showEditMemberDialog(BuildContext context, FamilyUser member) {
    final nameController = TextEditingController(text: member.displayName);

    showDialog(
      context: context,
      builder: (_) {
        bool roleIsParent = member.role;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Редактировать участника'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Имя'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<bool>(
                    value: roleIsParent,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Родитель')),
                      DropdownMenuItem(value: false, child: Text('Ребёнок')),
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
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Члены семьи',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Нет доступных членов семьи.'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Text(
            'Члены семьи',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...members.map(
          (member) => Stack(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: member.avatarUrl.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: 
                               NetworkImage(member.avatarUrl),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.blue.shade200,
                          child: Text(
                            member.displayName.substring(0,2).toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),

                  title: Text(member.displayName),
                  subtitle: Text(member.role ? 'Родитель' : 'Ребёнок'),
                  trailing: role
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditMemberDialog(context, member);
                          },
                        )
                      : null,
                ),
              ),
              if (member.id == currentUserId || member.userId == currentUserId)
                const Positioned(
                  top: 10,
                  left: 16,
                  child: Icon(Icons.star, color: Colors.green),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
