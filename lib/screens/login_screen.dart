import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final TextEditingController nameController =
      TextEditingController();

  Future<void> saveName() async {
    if (nameController.text.trim().isEmpty) return;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'username',
      nameController.text.trim(),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff050816),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                color: Colors.white,
                size: 90,
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome to StudyMate AI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText:
                      "Enter Your Name",
                  hintStyle:
                      const TextStyle(
                    color:
                        Colors.white54,
                  ),
                  filled: true,
                  fillColor:
                      Colors.white10,
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                16),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: saveName,
                child:
                    const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}