import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final String? username =
      prefs.getString('username');

  runApp(
    StudyMateAI(
      isLoggedIn: username != null,
    ),
  );
}

class StudyMateAI extends StatelessWidget {
  final bool isLoggedIn;

  const StudyMateAI({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyMate AI',
      theme: ThemeData.dark(),
      home: isLoggedIn
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}