// presentation/cubit/edit_family_member_cubit.dart

import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/repositories/family_users_repository.dart';
import 'package:family_tracker/presentation/cubit/family_member_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditFamilyMemberCubit extends Cubit<EditFamilyMemberState> {
  final FamilyUsersRepository _familyUsersRepository;

  EditFamilyMemberCubit(this._familyUsersRepository)
      : super(const EditFamilyMemberState());

  Future<void> updateMember(FamilyUser updatedUser) async {
    emit(state.copyWith(
      status: EditFamilyMemberStatus.loading,
      errorMessage: null,
    ));

    try {
      final saved = await _familyUsersRepository.updateFamilyUser(updatedUser);
      emit(state.copyWith(
        status: EditFamilyMemberStatus.success,
        updatedUser: saved,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditFamilyMemberStatus.error,
        errorMessage: 'Не удалось сохранить изменения: $e',
      ));
    }
  }

 
  /// Сбросить состояние (например, при закрытии экрана редактирования)
  void reset() => emit(const EditFamilyMemberState());
}