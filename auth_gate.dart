import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kadin/screens/auth/register_0r_login_screen.dart';
import 'package:kadin/screens/home/home_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Haddii user-ku uu galiyay
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen(
            
          ); // Redirect to home screen
        }

        // Haddii user-ku aanu gashin
        return const Register0rLoginScreen(); // Show login/register screen
      },
    );
  }
}
