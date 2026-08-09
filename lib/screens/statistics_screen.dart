import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int completedSessions = 0;
  int todayStudyMinutes = 0;
  int totalStudyMinutes = 0;
  String topTask = "None";
  Map<String, dynamic> studyHistory = {};

  List<dynamic> tasks = [];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson =
    prefs.getString('studyHistory');

if (historyJson != null) {
  studyHistory =
      jsonDecode(historyJson);
}

    setState(() {
      completedSessions =
          prefs.getInt('completedSessions') ?? 0;

      todayStudyMinutes =
          prefs.getInt('todayStudyMinutes') ?? 0;

      totalStudyMinutes =
          prefs.getInt('totalStudyMinutes') ?? 0;

      final tasksJson =
          prefs.getString('tasks');

      if (tasksJson != null) {
  tasks = jsonDecode(tasksJson);

  if (tasks.isNotEmpty) {
    tasks.sort(
      (a, b) => (b['completedSessions'] ?? 0)
          .compareTo(a['completedSessions'] ?? 0),
    );

    topTask = tasks.first['title'];
  }
  
}
    });
  }

List<BarChartGroupData> getWeeklyBars() {
  List<String> last7Days = [];

  for (int i = 6; i >= 0; i--) {
    final date = DateTime.now().subtract(
      Duration(days: i),
    );

    last7Days.add(
      date.toString().split(' ')[0],
    );
  }

  return List.generate(
    last7Days.length,
    (index) {
      double minutes =
          (studyHistory[last7Days[index]] ?? 0)
              .toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: minutes,
            width: 18,
            color: index == 6
    ? Colors.green
    : Colors.blue,
          ),
        ],
      );
    },
  );
}

List<PieChartSectionData> getPieSections() {
  final colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
  ];

  return List.generate(tasks.length, (index) {
    final task = tasks[index];

    return PieChartSectionData(
      value: (task['completedSessions'] ?? 0).toDouble(),
      title: "",
      color: colors[index % colors.length],
      radius: 100,
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Completed Sessions: $completedSessions",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Today's Study Time: $todayStudyMinutes min",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),


            const SizedBox(height: 10),

            Text(
              "Total Study Time: $totalStudyMinutes min",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          "🏆 Most Studied Task",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          topTask,
          style: TextStyle(
            fontSize: 24,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 20),

const SizedBox(height: 30),

const Text(
  "Study Distribution",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

SizedBox(
  height: 320,
  child: PieChart(
    PieChartData(
      sections: getPieSections(),
      centerSpaceRadius: 20,
      sectionsSpace: 3,
    ),
  ),
),

const SizedBox(height: 20),

Wrap(
  spacing: 20,
  runSpacing: 10,
  children: List.generate(tasks.length, (index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    return SizedBox(
      width: 180,
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            color: colors[index % colors.length],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tasks[index]['title'],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }),
),
const SizedBox(height: 30),

const SizedBox(height: 30),

const Text(
  "Weekly Study Graph(Minutes)",
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

SizedBox(
  height: 250,
  width: double.infinity,
  child: BarChart(
    BarChartData(
  borderData: FlBorderData(show: false),

  gridData: FlGridData(show: true),

  titlesData: FlTitlesData(
    topTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          const days = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat'
];

         return Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Text(
    days[value.toInt()],
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
);
        },
      ),
    ),
  ),

  barGroups: getWeeklyBars(),
),
  ),
),

const SizedBox(height: 20),

const Text(
  "Task-wise Progress",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...tasks.map(
              (task) => Card(
                child: ListTile(
                  title: Text(task['title']),
                  subtitle: Text(
                    "Sessions: ${task['completedSessions']}",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}