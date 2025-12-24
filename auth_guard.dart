// lib/utils/auth_guard.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kadin/screens/auth/register_0r_login_screen.dart';// ama auth_page.dart haddii aad halkaas dirto

Future<void> requireAuth(BuildContext context, VoidCallback onAuthenticated) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    // Haddii user aanu login ahayn, u dir login/register
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Register0rLoginScreen()),
    );
  } else {
    // Haddii uu login yahay, sii wad action-kii
    onAuthenticated();
  }
}
