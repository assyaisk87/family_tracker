import 'package:family_tracker/features/tasks/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final taskRepositoryProvider = Provider((ref) {
  return TaskRepository(Supabase.instance.client);
});
