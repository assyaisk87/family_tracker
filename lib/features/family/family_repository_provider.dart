import 'package:family_tracker/features/family/family_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final familyRepositoryProvider = Provider((ref) {
  return FamilyRepository(Supabase.instance.client);
});