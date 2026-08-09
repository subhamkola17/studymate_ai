import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'subjects_screen.dart';
import 'notes_screen.dart';
import 'tasks_screen.dart';
import 'timer_screen.dart';
import 'routine_screen.dart';
import 'progress_screen.dart';
import 'statistics_screen.dart';
import 'ai_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String userName = "Student";

  Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('username');

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );
}

  @override
  void initState() {
    super.initState();

    loadUserName();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  Future<void> loadUserName() async {
  final prefs = await SharedPreferences.getInstance();

  String name =
      prefs.getString('username') ?? "Student";

  if (name.isNotEmpty) {
    name =
        name[0].toUpperCase() +
        name.substring(1);
  }

  setState(() {
    userName = name;
  });
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildCard(
    IconData icon,
    String title,
    VoidCallback onTap,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + index * 120),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 25,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.03),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff7B61FF),

icon: const Icon(Icons.smart_toy),

label: const Text(
  "AI Tutor",
  style: TextStyle(
    fontWeight: FontWeight.bold,
  ),
),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AiScreen(),
            ),
          );
        },
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1 + _controller.value,
                      -1,
                    ),
                    end: Alignment(
                      1,
                      1 - _controller.value,
                    ),
                    colors: const [
                      Color(0xff050816),
                      Color(0xff0B1026),
                      Color(0xff121A3A),
                      Color(0xff050816),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 100,
                left: 50,
                child: circle(140),
              ),

              Positioned(
                bottom: 150,
                right: 40,
                child: circle(180),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      "StudyMate AI",
      style: TextStyle(
        color: Colors.white,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    ),

    IconButton(
      onPressed: logout,
      icon: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
      tooltip: "Logout",
    ),
  ],
),

SizedBox(height: 10),

                      Text(
                        "Welcome Back, $userName 👋",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Every study session brings you closer to success.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 6),

Text(
  DateFormat('dd MMMM yyyy')
      .format(DateTime.now()),
  style: TextStyle(
    color: Colors.white.withValues(alpha: 0.55),
  ),
),

                     const SizedBox(height: 25),

Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: Colors.white.withValues(alpha: 0.05),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.12),
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: const [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "8",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Features",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "AI",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Powered",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "24/7",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Available",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 20),

Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.count(
                              crossAxisCount:
                                  constraints.maxWidth > 900
                                      ? 4
                                      : constraints.maxWidth > 600
                                          ? 3
                                          : 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 1.05,
                              children: [
                                buildCard(
                                  Icons.menu_book_rounded,
                                  "Subjects",
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SubjectsScreen(),
                                    ),
                                  ),
                                  0,
                                ),
                                buildCard(
                                  Icons.edit_note_rounded,
                                  "Notes",
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotesScreen(),
                                    ),
                                  ),
                                  1,
                                ),
                                buildCard(
                                  Icons.task_alt_rounded,
                                  "Tasks",
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TasksScreen(),
                                    ),
                                  ),
                                  2,
                                ),
                                buildCard(
                                  Icons.timer_rounded,
                                  "Study Timer",
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TimerScreen(),
                                    ),
                                  ),
                                  3,
                                ),
                                buildCard(
                                  Icons.calendar_month_rounded,
                                  "Routine",
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RoutineScreen(),
                                    ),
                                  ),
                                  4,
                                ),
                                buildCard(
                                  Icons.trending_up_rounded,
                                  "Progress",
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ProgressScreen(),
                                    ),
                                  ),
                                  5,
                                ),
                                buildCard(
                                  Icons.analytics_rounded,
                                  "Statistics",
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const StatisticsScreen(),
                                    ),
                                  ),
                                  6,
                                ),
                                buildCard(
                                  Icons.smart_toy_rounded,
                                  "AI Assistant",
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AiScreen(),
                                    ),
                                  ),
                                  7,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}