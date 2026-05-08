import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/repositories/family_users_repository.dart';
import 'package:family_tracker/locator.dart';
import 'package:family_tracker/presentation/cubit/family_member_cubit.dart';
import 'package:family_tracker/presentation/cubit/family_member_state.dart';
import 'package:family_tracker/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      // ✅ BlocProvider создаётся внутри диалога — cubit живёт пока открыт диалог
      builder: (dialogContext) => BlocProvider(
        create: (_) => EditFamilyMemberCubit(locator<FamilyUsersRepository>()),
        child: _EditMemberDialog(
          member: member,
          nameController: nameController,
          // ✅ передаём ProfileCubit снаружи, чтобы обновить список после сохранения
          profileCubit: context.read<ProfileCubit>(),
        ),
      ),
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
                          onPressed: () =>
                              _showEditMemberDialog(context, member),
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

// ─────────────────────────────────────────────────────────────
// Отдельный StatefulWidget для диалога — чтобы корректно
// работал setState для переключения роли и BlocConsumer
// ─────────────────────────────────────────────────────────────

class _EditMemberDialog extends StatefulWidget {
  final FamilyUser member;
  final TextEditingController nameController;
  final ProfileCubit profileCubit;

  const _EditMemberDialog({
    required this.member,
    required this.nameController,
    required this.profileCubit,
  });

  @override
  State<_EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<_EditMemberDialog> {
  late bool _roleIsParent;

  @override
  void initState() {
    super.initState();
    _roleIsParent = widget.member.role;
  }

  @override
  void dispose() {
    widget.nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditFamilyMemberCubit, EditFamilyMemberState>(
      listener: (context, state) {
        if (state.status == EditFamilyMemberStatus.success) {
          // ✅ Обновляем список в ProfileScreen после успешного сохранения
          widget.profileCubit.loadProfile();
          Navigator.pop(context);
        }

        if (state.status == EditFamilyMemberStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Ошибка сохранения'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == EditFamilyMemberStatus.loading;

        return AlertDialog(
          title: const Text('Редактировать участника'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.nameController,
                enabled: !isLoading,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              const SizedBox(height: 16),
              DropdownButton<bool>(
                value: _roleIsParent,
                isExpanded: true,
                // ✅ блокируем дропдаун во время загрузки
                onChanged: isLoading
                    ? null
                    : (val) {
                        if (val != null) setState(() => _roleIsParent = val);
                      },
                items: const [
                  DropdownMenuItem(value: true, child: Text('Родитель')),
                  DropdownMenuItem(value: false, child: Text('Ребёнок')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      // ✅ вызываем cubit с обновлённым FamilyUser
                      final updated = FamilyUser(
                        id: widget.member.id,
                        familyId: widget.member.familyId,
                        userId: widget.member.userId,
                        displayName: widget.nameController.text.trim(),
                        avatarUrl: widget.member.avatarUrl,
                        role: _roleIsParent,
                      );
                      context
                          .read<EditFamilyMemberCubit>()
                          .updateMember(updated);
                    },
              // ✅ показываем индикатор загрузки вместо текста
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}