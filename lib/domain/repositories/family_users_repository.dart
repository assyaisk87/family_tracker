import '../entities/family_user.dart';


abstract class FamilyUsersRepository {
  Future<List<FamilyUser>> getFamilyUsers(int familyId);
  Future<FamilyUser> updateFamilyUser(FamilyUser upatedUser);
}