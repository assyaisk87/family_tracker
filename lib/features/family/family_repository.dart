import 'package:family_tracker/model/family_member.dart';
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
  final client = Supabase.instance.client;

  await client
      .from('family_members')
      .update({'avatar_url': avatarUrl})
      .eq('id', memberId);
}

Future<FamilyMember> getFamilyMember(int memberId) async{
  final member = await client
          .from('family_members')
          .select()
          .eq('id', memberId)
          .maybeSingle();
          
  if (member == null) throw Exception("Семья не найдена");
           return FamilyMember.fromJson(member);
}
}
