import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kadin/screens/home/Nevication_bar.dart';
import 'package:kadin/maintenance/closed_screen.dart';
import 'package:kadin/time_check.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1️⃣ Animation controller (logo fade)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // 2️⃣ Bilaab flow-ga splash
    _startFlow();
  }

  Future<void> _startFlow() async {
    // 👉 Splash ha joogo 3 sec
    await Future.delayed(const Duration(seconds: 3));

    // 👉 Hubin fudud (time check)
    final allowed = await isWithinAllowedTime();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                allowed ? const BottomNavigationWidget() : const ClosedScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'images/logoappbar.png',
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
