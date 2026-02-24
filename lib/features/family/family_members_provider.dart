import 'package:family_tracker/features/session/session_provider.dart';
import 'package:family_tracker/model/family_member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final familyMembersProvider =
    FutureProvider<List<FamilyMember>>((ref) async {

  final sessionAsync = ref.watch(sessionProvider);

  return sessionAsync.when(
    data: (session) async {
      if (session == null || session.family == null) {
        return [];
      }

      final client = Supabase.instance.client;

      final response = await client
          .from('family_members')
          .select()
          .eq('family_id', session.family!.id);

      return (response as List)
          .map((e) => FamilyMember.fromJson(e))
          .toList();
    },
    loading: () async => [],
    error: (_, _) async => [],
  );
});
