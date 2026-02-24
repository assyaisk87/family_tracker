import 'package:family_tracker/model/task_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskFilterProvider =
    StateProvider<TaskFilter>((ref) => const TaskFilter());