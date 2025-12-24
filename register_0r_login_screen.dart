import 'package:flutter/material.dart';
import 'package:kadin/screens/auth/login_screen.dart';
import 'package:kadin/screens/home/home_screen.dart';

class Register0rLoginScreen extends StatefulWidget {
  const Register0rLoginScreen({super.key});

  @override
  State<Register0rLoginScreen> createState() => _Register0rLoginScreen();
}

class _Register0rLoginScreen extends State<Register0rLoginScreen> {
  // intialize show login screen
  bool showLoginScreen = true;

  // intialize show register screen
  void toggleScreens() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen) {
      return LoginScreen();
    } else {
      return HomeScreen();
    }
  }
}
