class TaskFilter {
  final int assigneeId; // 0 = все
  final bool sortByDateAsc;

  const TaskFilter({
    this.assigneeId = 0,
    this.sortByDateAsc = true,
  });

  TaskFilter copyWith({
    int? assigneeId,
    bool? sortByDateAsc,
  }) {
    return TaskFilter(
      assigneeId: assigneeId ?? this.assigneeId,
      sortByDateAsc: sortByDateAsc ?? this.sortByDateAsc,
    );
  }
}
