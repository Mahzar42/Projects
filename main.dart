import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kadin/firebase_options.dart';
import 'package:kadin/screens/auth/splash_screen.dart';
import 'package:kadin/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Push Notification bilow
  await PushNotificationService().init();

  runApp(const Miiraale());
}

// NavigatorKey waxaa loo isticmaalayaa in notification click
// uu screen kale u furo xitaa app-ku hadduu xirnaa
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Miiraale extends StatelessWidget {
  const Miiraale({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // MUHIIM
      home: SplashScreen(),
      // FutureBuilder<bool>(
      //   future: isWithinAllowedTime(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(
      //         body: Center(child: CircularProgressIndicator()),
      //       );
      //     } else if (snapshot.hasError) {
      //       return const ClosedScreen(); // fallback haddii error dhaco
      //     } else {
      //       return snapshot.data == true
      //           ? const SplashScreen()
      //           : const ClosedScreen();
      //     }
      //   },
      // ),
    );
  }
}
