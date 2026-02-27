class TaskFilter {
  final int assigneeId; // 0 = все
  final bool sortByDateAsc;
  final bool hideOverdue;

  const TaskFilter({
    this.assigneeId = 0,
    this.sortByDateAsc = true,
    this.hideOverdue = false,
  });

  TaskFilter copyWith({
    int? assigneeId,
    bool? sortByDateAsc,
    bool? hideOverdue,
  }) {
    return TaskFilter(
      assigneeId: assigneeId ?? this.assigneeId,
      sortByDateAsc: sortByDateAsc ?? this.sortByDateAsc,
      hideOverdue: hideOverdue ?? this.hideOverdue,
    );
  }
}
