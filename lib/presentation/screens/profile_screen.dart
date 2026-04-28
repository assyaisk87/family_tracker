import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/family_users_repository.dart';
import 'package:family_tracker/locator.dart';
import 'package:family_tracker/presentation/cubit/profile_cubit.dart';
import 'package:family_tracker/presentation/cubit/profile_state.dart';
import 'package:family_tracker/presentation/widgets/family_users_section.dart';
import 'package:family_tracker/presentation/widgets/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        locator<AuthRepository>(),
        locator<FamilyUsersRepository>(),
      )..loadProfile(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Профиль'),
              actions: [
                IconButton(
                  onPressed: () async {
                    try {
                      await context.read<ProfileCubit>().signOut();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    } catch (e) {
                      print('Ошибка выхода: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка выхода: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state.status == ProfileStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ProfileStatus.error) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'Ошибка загрузки профиля',
                    ),
                  );
                }

                final user = state.user;
                if (user == null) {
                  return const Center(child: Text('Профиль не найден'));
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileHeader(user: user, isOwnProfile: true),
                      FamilyMembersSection(
                        familyId: int.tryParse(user.familyId) ?? 0,
                        currentUserId: state.currentUserId ?? '',
                        role: state.currentUserIsParent,
                        members: state.familyMembers,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
