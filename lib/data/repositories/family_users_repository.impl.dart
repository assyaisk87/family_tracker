import 'package:family_tracker/data/datasources/family_users_data_source.dart';
import 'package:family_tracker/domain/entities/family_user.dart';
import 'package:family_tracker/domain/repositories/family_users_repository.dart';

class FamilyUsersRepositoryImpl implements FamilyUsersRepository {
  final FamilyUsersRemoteDataSource remoteDataSource;

  FamilyUsersRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<FamilyUser>> getFamilyUsers(int familyId) async {
    final familyUsers = await remoteDataSource.fetchFamilyUsers(familyId);
    return familyUsers.map((it) => it.toDomain()).toList();
  }

  @override
  Future<FamilyUser> updateFamilyUser(FamilyUser updatedUser) async {
     final familyUser = await remoteDataSource.updateFamilyUser(updatedUser);
    return familyUser.toDomain();
  }
}
