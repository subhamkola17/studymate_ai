import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'dart:convert';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int seconds = 1500;  // 25 minutes
  int totalSeconds = 1500; 
  Timer? timer;
  bool isRunning = false;

  AudioPlayer player = AudioPlayer();
 Future<void> playBell() async {
  try {
    await player.stop();
    await player.setSource(AssetSource('bell.mp3'));
    await player.resume();
  } catch (e) {
    print("Bell Error: $e");
  }
}
  int completedSessions = 0;
  int selectedMinutes = 25;
  int todayStudyMinutes = 0;
  int totalStudyMinutes = 0;
String lastStudyDate = "";
List<Task> tasks = [];

Task? selectedTask;

Future<void> loadTasks() async {
  final prefs = await SharedPreferences.getInstance();

  final String? tasksJson = prefs.getString('tasks');

  if (tasksJson != null) {
    final List decoded = jsonDecode(tasksJson);

    setState(() {
      tasks = decoded.map((item) {
        return Task(
          title: item['title'],
          isDone: item['isDone'],
          completedSessions: item['completedSessions'] ?? 0,
        );
      }).toList();
    });
  }
}

  @override
void initState() {
  super.initState();
  loadSessions();
  loadTasks();
}

  Future<void> loadSessions() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
  completedSessions =
      prefs.getInt('completedSessions') ?? 0;

  todayStudyMinutes =
      prefs.getInt('todayStudyMinutes') ?? 0;

  totalStudyMinutes =
      prefs.getInt('totalStudyMinutes') ?? 0;

  lastStudyDate =
      prefs.getString('lastStudyDate') ?? "";

  String today =
      DateTime.now().toString().split(' ')[0];

  if (lastStudyDate != today) {
    todayStudyMinutes = 0;
    lastStudyDate = today;
  }
});
}

Future<void> saveSessions() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt(
    'completedSessions',
    completedSessions,
  );
  await prefs.setInt(
  'todayStudyMinutes',
  todayStudyMinutes,
);
await prefs.setInt(
  'totalStudyMinutes',
  totalStudyMinutes,
);

await prefs.setString(
  'lastStudyDate',
  lastStudyDate,
);

String today =
    DateTime.now().toString().split(' ')[0];

String? historyJson =
    prefs.getString('studyHistory');

Map<String, dynamic> history =
    historyJson != null
        ? jsonDecode(historyJson)
        : {};

history[today] =
    (history[today] ?? 0) + selectedMinutes;

await prefs.setString(
  'studyHistory',
  jsonEncode(history),
);

final tasksJson = jsonEncode(
  tasks.map((task) => {
    'title': task.title,
    'isDone': task.isDone,
    'completedSessions': task.completedSessions,
  }).toList(),
);

await prefs.setString('tasks', tasksJson);
}

  void startTimer() {
    if (isRunning) return;

    isRunning = true;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
     } else {
  timer.cancel();

  setState(() {
  isRunning = false;

  completedSessions++;

  todayStudyMinutes += selectedMinutes;

  totalStudyMinutes += selectedMinutes;

  lastStudyDate =
      DateTime.now().toString().split(' ')[0];

  if (selectedTask != null) {
    selectedTask!.completedSessions++;
  }
});

saveSessions();

  playBell();
  setState(() {
  seconds = selectedMinutes * 60;
  totalSeconds = selectedMinutes * 60;
});

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Session Complete"),
      content: const Text(
        "Great job! Your study session is finished.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
    });
  }

  void pauseTimer() {
    timer?.cancel();
    isRunning = false;
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      seconds = selectedMinutes * 60;
      isRunning = false;
    });
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int secs = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
void dispose() {
  timer?.cancel();
  player.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Timer"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
         children: [

  const Text(
    "Select Task",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 10),

  DropdownButton<Task>(
    value: selectedTask,
    hint: const Text("Choose Task"),
    items: tasks.map((task) {
      return DropdownMenuItem<Task>(
        value: task,
        child: Text(task.title),
      );
    }).toList(),
    onChanged: (task) {
      setState(() {
        selectedTask = task;
      });
    },
  ),

  const SizedBox(height: 20),

  Stack(
  alignment: Alignment.center,
  children: [
    SizedBox(
      width: 220,
      height: 220,
      child:CircularProgressIndicator(
  value: seconds / totalSeconds,
  strokeWidth: 12,
  backgroundColor: Colors.grey.shade800,
)
    ),

    Text(
      formatTime(seconds),
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),

const SizedBox(height: 20),

DropdownButton<int>(
  value: selectedMinutes,
  items: const [
    DropdownMenuItem(
      value: 25,
      child: Text("25 Minutes"),
    ),
    DropdownMenuItem(
      value: 45,
      child: Text("45 Minutes"),
    ),
    DropdownMenuItem(
      value: 60,
      child: Text("60 Minutes"),
    ),
  ],
  onChanged: (value) {
    setState(() {
      selectedMinutes = value!;
      seconds = selectedMinutes * 60;
      totalSeconds = selectedMinutes * 60;
    });
  },
),

const SizedBox(height: 20),

Text(
  "Completed Sessions: $completedSessions",
  style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
Text(
  'Today\'s Study Time: $todayStudyMinutes min',
  style: const TextStyle(fontSize: 18),
),

const SizedBox(height: 8),

Text(
  'Total Study Time: $totalStudyMinutes min',
  style: const TextStyle(fontSize: 18),
),

const SizedBox(height: 40),

            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton.icon(
      onPressed: startTimer,
      icon: const Icon(Icons.play_arrow),
      label: const Text("Start"),
    ),

    const SizedBox(width: 10),

    ElevatedButton.icon(
      onPressed: pauseTimer,
      icon: const Icon(Icons.pause),
      label: const Text("Pause"),
    ),

    const SizedBox(width: 10),

    ElevatedButton.icon(
      onPressed: resetTimer,
      icon: const Icon(Icons.refresh),
      label: const Text("Reset"),
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}