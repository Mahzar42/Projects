import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:kadin/components/constrac.dart';
import 'package:kadin/screens/Footer Page/caawiye_screen.dart';
import 'package:kadin/screens/auth/choose_screen.dart';
import 'package:kadin/screens/home/search_screen.dart';
import 'package:kadin/screens/product/games_screen.dart';
import 'package:kadin/screens/home/home_screen.dart';
import 'package:kadin/screens/profile/profile_screen.dart';
import 'package:kadin/services/push_notification_service.dart';

// ================================
// WIDGET-KA BOTTOM NAVIGATION
// ================================
class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({super.key});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _currentIndex = 2; // Default: Home screen

  // Liiska screens-ka la beddelayo marka navigation la taabto
  final List<Widget> _screens = const [
    CaawiyeScreen(), // Screen 0
    SearchScreen(), // Screen 1
    HomeScreen(), // Screen 2 (default)
    GamesScreen(), // Screen 3
    ChooseScreen(), // Screen 4 (login/profile)
  ];

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        PushNotificationService.init(user.uid);
      }

      if (_currentIndex == 4 && user == null) {
        setState(() => _currentIndex = 0);
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Haddii user aan login ahayn oo uu taabto profile, wuxuu dib ugu celiyaa screen-ka koowaad
  //   FirebaseAuth.instance.authStateChanges().listen((user) {
  //      if (user != null) {
  //     // 👇 Notification hal mar oo keliya
  //     await PushNotificationService.init(user.uid);
  //   }
  //     if (_currentIndex == 4 && user == null) {
  //       setState(() => _currentIndex = 0);
  //     }
  //   });

  //   // 👇 HALKAN AYAAD KU DARAYSAA
  //   PushNotificationService.init(FirebaseAuth.instance.currentUser!.uid);
  // }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // User-ka hadda jira
    final width = MediaQuery.of(context).size.width; // Ballaca shaashadda

    // ================================
    // Dejinta responsive (mobile, tablet, web)
    // ================================
    double navHeight; // Dhererka bottom nav
    double iconSizeMain; // Icon-ka weyn (Home)
    double iconSize; // Icons-ka kale
    double paddingTop; // Padding-ka kore

    if (width < 600) {
      navHeight = 80;
      iconSizeMain = 36;
      iconSize = 30;
      paddingTop = 14;
    } else if (width < 1000) {
      navHeight = 88;
      iconSizeMain = 40;
      iconSize = 34;
      paddingTop = 16;
    } else {
      navHeight = 100;
      iconSizeMain = 46;
      iconSize = 40;
      paddingTop = 18;
    }

    return Scaffold(
      extendBody: true, // Si nav-ka uu u muuqdo "floating" effect
      // ================================
      // Body: Screen-ka hadda jira
      // ================================
      body:
          _currentIndex == 4
              ? (user == null ? const ChooseScreen() : const ProfileScreen())
              : _screens[_currentIndex],

      // ================================
      // BOTTOM NAVIGATION BAR
      // ================================
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(100), // Xagasha wareegsan
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Blur effect
          child: Container(
            height: navHeight,
            padding: EdgeInsets.only(top: paddingTop),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32), // Isla xagasha
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
              ), // Xuduud
              boxShadow: [
                BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),

            // ================================
            // Curved Navigation Bar
            // ================================
            child: CurvedNavigationBar(
              index: _currentIndex,
              height: navHeight * 0.65,
              backgroundColor: Colors.transparent,
              color: Colors.transparent,
              buttonBackgroundColor: Colors.transparent,
              animationCurve: Curves.easeOutExpo,
              animationDuration: const Duration(milliseconds: 380),

              // Liiska icons
              items: [
                _navIcon(
                  Icons.help_outline_rounded,
                  0,
                  iconSize: iconSize,
                ), // Caawiye
                _navIcon(Icons.search_rounded, 1, iconSize: iconSize), // Search
                _navIcon(
                  Icons.home_rounded,
                  2,
                  isMain: true,
                  iconSize: iconSizeMain,
                ), // Home (Main)
                _navIcon(
                  Icons.sports_esports_rounded,
                  3,
                  iconSize: iconSize,
                ), // Games
                _navIcon(
                  Icons.person_rounded,
                  4,
                  iconSize: iconSize,
                ), // Profile
              ],

              // Markii icon la taabto
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ),
      ),
    );
  }

  // ================================
  // FUNCTION: Icon Item (premium animation)
  // ================================
  Widget _navIcon(
    IconData icon,
    int index, {
    bool isMain = false,
    double iconSize = 30,
  }) {
    final isSelected = _currentIndex == index;

    return AnimatedScale(
      scale: isSelected ? 1.15 : 1.0, // Marka la xusho weynaanaya
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(isMain ? 10 : 9), // Padding gudaha icon
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isSelected ? kNavyBlue : Colors.transparent, // Background midab
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      // color: kSoftWhite.withOpacity(0.65), // Shadow effect
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : [],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: kSoftWhite, // Midabka icon
        ),
      ),
    );
  }
}
