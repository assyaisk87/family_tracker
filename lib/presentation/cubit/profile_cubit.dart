import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/entities/user.dart';
import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/domain/repositories/family_users_repository.dart';
import 'package:family_tracker/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;
  final FamilyUsersRepository _familyUsersRepository;

  ProfileCubit(this._authRepository, this._familyUsersRepository)
    : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));

    try {
      final authUser = await _authRepository.getCurrentUserWithFamily();
      if (authUser == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'Пользователь не авторизован',
          ),
        );
        return;
      }

      final familyMembers = authUser.familyId != null
          ? await _familyUsersRepository.getFamilyUsers(
              int.parse(authUser.familyId!),
            )
          : <FamilyUser>[];

      String username = authUser.email.split('@').first;
      String avatarUrl = '';
      bool currentUserIsParent = false;

      for (final member in familyMembers) {
        if (member.id == authUser.id || member.userId == authUser.id) {
          if (member.displayName.isNotEmpty) {
            username = member.displayName;
          }
          avatarUrl = member.avatarUrl;
          currentUserIsParent = member.role;
          break;
        }
      }

      final profileUser = User(
        id: authUser.id,
        username: username,
        avatarUrl: avatarUrl,
        familyId: authUser.familyId ?? '',
        email: authUser.email,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: profileUser,
          familyMembers: familyMembers,
          currentUserId: authUser.id,
          currentUserIsParent: currentUserIsParent,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Ошибка загрузки профиля: $e',
        ),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(
        state.copyWith(
          status: ProfileStatus.initial,
          user: null,
          familyMembers: [],
          currentUserId: null,
          currentUserIsParent: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      print('Ошибка выхода: $e');
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Ошибка выхода: $e',
        ),
      );
      rethrow;
    }
  }
}
