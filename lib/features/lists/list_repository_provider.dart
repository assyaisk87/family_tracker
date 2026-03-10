import 'package:family_tracker/features/lists/list_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final listRepositoryProvider = Provider((ref) {
  return ListRepository(Supabase.instance.client);
});
