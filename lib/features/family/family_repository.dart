import 'package:family_tracker/model/family.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyRepository {
  final SupabaseClient client;

  FamilyRepository(this.client);

  Future<void> updateFamilyName(int familyId, String newName) async {
    await client
        .from('families')
        .update({'name': newName})
        .eq('id', familyId);
  }

  Future<void> updateMember(FamilyMember member) async {
    await client
        .from('family_members')
        .update({
          'display_name': member.displayName,
          'role': member.role,
        })
        .eq('id', member.id);
  }

  Future<void> updateAvatar(String memberId, String avatarUrl) async {
    await client
        .from('family_members')
        .update({'avatar_url': avatarUrl})
        .eq('id', memberId);
  }

  Future<void> uploadAndUpdateAvatar(int memberId, String userId, XFile image) async {
    final bytes = await image.readAsBytes();
    final filePath = 'avatars/$userId.png';

    // Загружаем файл в storage
    await client.storage.from('avatars').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    // Получаем публичный URL
    final url = client.storage.from('avatars').getPublicUrl(filePath);

    // Обновляем аватар в БД
    await updateAvatar(memberId.toString(), url);
  }

  Future<FamilyMember> getFamilyMember(int memberId) async {
    final member = await client
        .from('family_members')
        .select()
        .eq('id', memberId)
        .maybeSingle();

    if (member == null) throw Exception("Участник семьи не найден");
    return FamilyMember.fromJson(member);
  }

  Future<FamilyModel> fetchFamily(int familyId) async {
    final familyData = await client
        .from('families')
        .select()
        .eq('id', familyId)
        .maybeSingle();

    if (familyData == null) throw Exception("Семья не найдена");
    return FamilyModel.fromJson(familyData);
  }

  Future<List<FamilyMember>> fetchFamilyMembers(int familyId) async {
    final response = await client
        .from('family_members')
        .select()
        .eq('family_id', familyId);

    return (response as List)
        .map((e) => FamilyMember.fromJson(e))
        .toList();
  }

  Future<FamilyMember?> fetchFamilyMemberByUserId(String userId) async {
    final member = await client
        .from('family_members')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return member != null ? FamilyMember.fromJson(member) : null;
  }
}
