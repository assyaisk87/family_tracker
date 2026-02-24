import 'package:family_tracker/features/session/session.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:family_tracker/model/family.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sessionProvider = StreamProvider<SessionData?>((ref) {
  final client = Supabase.instance.client;

  return client.auth.onAuthStateChange.asyncMap((data) async {
    final session = data.session;
    final user = session?.user;

    if (user == null) return null;

    try {
      // ищем запись в family_members
      final member = await client
          .from('family_members')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (member == null) {
        return SessionData(user: user);
      }

      final memberMap = member;

      // загружаем семью
      final familyData = await client
          .from('families')
          .select()
          .eq('id', memberMap['family_id'])
          .maybeSingle();

      return SessionData(
        user: user,
        member: FamilyMember.fromJson(memberMap),
        family: familyData != null
            ? FamilyModel.fromJson(familyData)
            : null,
        myMemberId: FamilyMember.fromJson(memberMap).id
      );
    } catch (e) {
      return null;
    }
  });
});
