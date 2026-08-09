import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int totalTasks = 0;
  int completedTasks = 0;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final String? tasksJson = prefs.getString('tasks');

    if (tasksJson != null) {
      final List decoded = jsonDecode(tasksJson);

      setState(() {
        totalTasks = decoded.length;

        completedTasks = decoded
            .where((task) => task['isDone'] == true)
            .length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        totalTasks == 0 ? 0 : completedTasks / totalTasks;
        String status;
        String motivation;

if (progress < 0.4) {
  motivation = "Keep Working 💪";
} else if (progress < 0.8) {
  motivation = "Great Job 🚀";
} else {
  motivation = "Excellent Work 🎉";
}

if (progress < 0.4) {
  status = "🔴 Needs Improvement";
} else if (progress < 0.8) {
 status = "🟠 Good Progress";
} else {
  status = "🟢 Excellent Work!";
}

        Color progressColor;

if (progress < 0.4) {
  progressColor = Colors.red;
} else if (progress < 0.8) {
  progressColor = Colors.orange;
} else {
  progressColor = Colors.green;
}

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.grey[900],
  elevation: 5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Study Progress",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: LinearProgressIndicator(
      value: progress,
      minHeight: 15,
      backgroundColor: Colors.grey.shade300,
      valueColor: AlwaysStoppedAnimation<Color>(
        progressColor,
      ),
    ),
  ),
),

            const SizedBox(height: 20),

            Center(
  child: Text(
    "Completed Tasks: $completedTasks",
    style: const TextStyle(fontSize: 18),
  ),
),
            const SizedBox(height: 10),

            Center(
  child: Text(
    "Total Tasks: $totalTasks",
    style: const TextStyle(fontSize: 18),
  ),
),

            const SizedBox(height: 10),

            Center(
  child: Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        width: 120,
        height: 120,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 10,
          color: progressColor,
          backgroundColor: Colors.grey.shade300,
        ),
      ),

      Text(
        "${(progress * 100).toInt()}%",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
            const SizedBox(height: 15),

Text(
  status,
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: progressColor,
  ),
),
const SizedBox(height: 10),

Text(
  motivation,
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: progressColor,
  ),
),
const SizedBox(height: 20),

Icon(
  Icons.emoji_events,
  size: 60,
  color: Colors.amberAccent,
),

const SizedBox(height: 10),

Text(
  progress >= 0.75
      ? "Achievement Unlocked!"
      : "Keep Going!",
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 20),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [
    Icon(
      Icons.local_fire_department,
      color: Colors.orange,
      size: 30,
    ),
    SizedBox(width: 8),
    Text(
      "3 Day Streak",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),
          ],
        ),
      ),
        ),
      ),
    );
  }
}