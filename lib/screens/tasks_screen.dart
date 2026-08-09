import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Task> tasks = [];
  @override
void initState() {
  super.initState();
  loadTasks();
}
Future<void> loadTasks() async {
  final prefs = await SharedPreferences.getInstance();

  final String? tasksJson = prefs.getString('tasks');
  print("LOADED: $tasksJson");

  if (tasksJson != null) {
    final List decoded = jsonDecode(tasksJson);

    setState(() {
      tasks = decoded.map((item) {
       return Task(
  title: item['title'],
  isDone: item['isDone'],
  completedSessions:
      item['completedSessions'] ?? 0,
);
      }).toList();
    });
  }
}Future<void> saveTasks() async {
  final prefs = await SharedPreferences.getInstance();

  final List taskList = tasks.map((task) {
    return {
  'title': task.title,
  'isDone': task.isDone,
  'completedSessions':
      task.completedSessions,
};
  }).toList();

  await prefs.setString(
    'tasks',
    jsonEncode(taskList),
  );
  print("SAVED: ${jsonEncode(taskList)}");
}

  void addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        tasks.add(
  Task(title: _controller.text),
);
      });
      saveTasks();
      _controller.clear();
    }
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter Task",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addTask,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          Text(
  "Total Tasks: ${tasks.length}",
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

Text(
  "Completed: ${tasks.where((task) => task.isDone).length}/${tasks.length}",
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  ),
),

const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
  color: tasks[index].isDone
      ? Colors.green.shade100
      : Colors.orange.shade100,
                 child: ListTile(
  leading: Checkbox(
    activeColor: Colors.green,
    value: tasks[index].isDone,
    onChanged: (value) {
      setState(() {
        tasks[index].isDone = value!;
        
      });
      saveTasks();
    },
  ),

  title: Text(
  tasks[index].title,
  style: TextStyle(
    color: tasks[index].isDone
    ? Colors.grey.shade700
    : Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    decoration: tasks[index].isDone
        ? TextDecoration.lineThrough
        : null,
        decorationThickness: 4,
decorationColor: Colors.red,
  ),
),

subtitle: Text(
  'Study Sessions: ${tasks[index].completedSessions}',
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.blue,
  ),
),



  trailing: IconButton(
  icon: const Icon(
    Icons.delete,
    color: Colors.red,
    size: 24,
  ),
  onPressed: () => deleteTask(index),
),
),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}