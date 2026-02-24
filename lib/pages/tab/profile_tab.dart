import 'package:family_tracker/features/auth/auth_provider.dart';
import 'package:family_tracker/features/family/family_members_provider.dart';
import 'package:family_tracker/features/family/family_provider.dart';
import 'package:family_tracker/features/family/family_repository_provider.dart';
import 'package:family_tracker/features/session/session_provider.dart';
import 'package:family_tracker/model/family.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:family_tracker/pages/tab/family_members_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  void _showEditFamilyDialog(
    BuildContext context,
    FamilyModel family,
    WidgetRef ref,
  ) {
    final nameController = TextEditingController(text: family.name);
    final repo = ref.read(familyRepositoryProvider);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Редактировать название семьи"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Название семьи"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () async {
              await repo.updateFamilyName(family.id, nameController.text);
              ref.invalidate(familyProvider(family.id));
              Navigator.pop(context);
            },
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );
  }

  void _browsImage(FamilyMember? member, WidgetRef ref) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final client = Supabase.instance.client;
    final filePath = 'avatars/${member?.userId}.png';

    await client.storage.from('avatars').uploadBinary(filePath, bytes);

    final url = client.storage.from('avatars').getPublicUrl(filePath);

    final repo = ref.read(familyRepositoryProvider);
    // используем готовую функцию
    await repo.updateAvatar(member!.id.toString(), url);

    // обновляем UI
    ref.invalidate(familyMembersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Ошибка: $e'))),
      data: (session) {
        if (session == null) {
          return const Scaffold(
            body: Center(child: Text('Нет данных пользователя')),
          );
        }

        final user = session.user;
        final family = session.family;
        final member = session.member;

        return Scaffold(
          appBar: AppBar(
            title: Text('Профиль'),
            actions: [
              IconButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.white,),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                //Avatar
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Аватар
                      CircleAvatar(
                        radius: 100,
                        backgroundImage:
                            member?.avatarUrl != null &&
                                member!.avatarUrl.isNotEmpty
                            ? NetworkImage(member.avatarUrl)
                            : null,
                      ),

                      // Полупрозрачная кнопка сверху
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black.withOpacity(0.25),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _browsImage(member, ref);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // EMAIL
                ListTile(
                  title: const Text("Email"),
                  subtitle: Text(user.email ?? ''),
                ),

                const SizedBox(height: 12),

                // FAMILY
                if (member?.role == true)
                  ListTile(
                    title: const Text("Название семьи"),
                    subtitle: Text(family?.name ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showEditFamilyDialog(context, family!, ref),
                    ),
                  ),

                // if (member?.role == true)
                // const SizedBox(height: 12),

                // // ROLE
                // if (member?.role == true)
                // ListTile(
                //   title: const Text("Моя роль"),
                //   subtitle: Text(member?.role == true ? "Родитель" : "Ребёнок"),
                // ),

                const Divider(height: 32),

                if (family != null)
                  FamilyMembersSection(
                    familyId: family.id,
                    currentUserId: user.id,
                    role: member?.role ?? false,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
