class ListItem {
  final int id;
  final int? taskId;
  final String title;
  final bool completed;
  final int? orderIndex;
  final String? comment;

  ListItem({
    required this.id,
    this.taskId,
    required this.title,
    required this.completed,
    this.orderIndex,
    this.comment,
  });
  
  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'],
      taskId: json['task_id'] as int?,
      title: json['title'],
      completed: json['completed'] ?? false,
      orderIndex: json['order_index'] as int?,
      comment: json['comment'] as String?,      
    );
  }
}