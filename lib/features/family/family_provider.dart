import 'package:family_tracker/model/family.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final familyProvider = FutureProvider.family<FamilyModel, int>((ref, familyId) async {
  final client = Supabase.instance.client;
  final familyData = await client
      .from('families')
      .select()
      .eq('id', familyId)
      .maybeSingle();

  if (familyData == null) throw Exception("Семья не найдена");

  return FamilyModel.fromJson(familyData);
});