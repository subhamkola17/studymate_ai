import 'package:flutter/material.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final List<Map<String, dynamic>> routineItems = [
    {
      "time": "6:00 AM",
      "task": "Wake Up",
      "icon": Icons.access_time,
      "done": false,
    },
    {
      "time": "8:00 AM",
      "task": "Study",
      "icon": Icons.book,
      "done": false,
    },
    {
      "time": "10:00 AM",
      "task": "Classes",
      "icon": Icons.school,
      "done": false,
    },
    {
      "time": "6:00 PM",
      "task": "Revision",
      "icon": Icons.edit_note,
      "done": false,
    },
    {
      "time": "10:00 PM",
      "task": "Sleep",
      "icon": Icons.nightlight,
      "done": false,
    },
  ];

  void addRoutine() {
    TextEditingController timeController = TextEditingController();
    TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Routine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Time",
              ),
            ),
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: "Task",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (timeController.text.isNotEmpty &&
                  taskController.text.isNotEmpty) {
                setState(() {
                  routineItems.add({
                    "time": timeController.text,
                    "task": taskController.text,
                    "icon": Icons.task,
                    "done": false,
                  });
                });

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void editRoutine(int index) {
    TextEditingController timeController =
        TextEditingController(
      text: routineItems[index]["time"],
    );

    TextEditingController taskController =
        TextEditingController(
      text: routineItems[index]["task"],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Routine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeController,
            ),
            TextField(
              controller: taskController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                routineItems[index]["time"] =
                    timeController.text;

                routineItems[index]["task"] =
                    taskController.text;
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteRoutine(int index) {
    setState(() {
      routineItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    int completed = routineItems
        .where((item) => item["done"] == true)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Routine"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addRoutine,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          Text(
            "Completed: $completed / ${routineItems.length}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: LinearProgressIndicator(
              value: routineItems.isEmpty
                  ? 0
                  : completed / routineItems.length,
              minHeight: 10,
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: routineItems.length,
              itemBuilder: (context, index) {
                return Card(
                  color: routineItems[index]["done"]
                      ? Colors.green.shade100
                      : null,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: routineItems[index]["done"],
                      onChanged: (value) {
                        setState(() {
                          routineItems[index]["done"] =
                              value;
                        });
                      },
                    ),
                    title: Text(
                      "${routineItems[index]["time"]} - ${routineItems[index]["task"]}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () =>
                              editRoutine(index),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              deleteRoutine(index),
                        ),
                      ],
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