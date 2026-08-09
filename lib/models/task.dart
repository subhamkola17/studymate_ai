class Task {
  String title;
  bool isDone;
  int completedSessions;

  Task({
    required this.title,
    this.isDone = false,
    this.completedSessions = 0,
  });
}