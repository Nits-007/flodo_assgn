class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final int? blockedBy;

  Task({this.id, required this.title, required this.description, required this.dueDate, required this.status, this.blockedBy});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      blockedBy: json['blocked_by'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String().split('T')[0],
        'status': status,
        'blocked_by': blockedBy,
      };
}