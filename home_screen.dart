import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gap/gap.dart';
import 'package:kadin/auth_gate.dart';
import 'package:kadin/components/constrac.dart';
import 'package:kadin/screens/Footer%20Page/news_screen.dart';
import 'package:kadin/screens/product/account_product.dart';
import 'package:kadin/screens/product/product_game.dart';
import 'package:kadin/screens/product/productdetails_screen.dart';
import 'package:kadin/screens/profile/profile_screen.dart';
import 'package:kadin/services/push_notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> games = const [
    {"name": "Pubg Mobile", "image": "images/Global.png"},
    {"name": "Free fire", "image": "images/freefire.png"},
    {"name": "Clash of Clans", "image": "images/clashofclans.png"},
    // {"name": "Call of Duty", "image": "images/callofduty.jpg"},
    //{"name": "Delta Force", "image": "images/deltaforce.jpeg"},
  ];

  final List<Map<String, String>> accounts = const [
    {"name": "eFootball", "image": "images/efootballacc.jpg"},
    {"name": "Pubg Mobile", "image": "images/account.jpg"},
  ];

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> streamPopularGames() {
    return FirebaseFirestore.instance.collection('payments').snapshots().map((
      snapshot,
    ) {
      final Map<String, int> gameCounts = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final gameName = data['game'] as String?;
        if (gameName != null) {
          gameCounts[gameName] = (gameCounts[gameName] ?? 0) + 1;
        }
      }

      final sortedGames =
          gameCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      final top3 = sortedGames.take(3).toList();

      return top3.map((entry) {
        return {
          'game': entry.key,
          'image': 'image${entry.key.toLowerCase()}.png',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: kbluebg,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 6,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            children: [
              Image.asset('images/logoappbar.png', height: 40),
              const SizedBox(width: 1),
              const Text(
                'Kadin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (user == null) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.newspaper,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Gap(25),
                _buildBanners(
                  height: 290,
                  collectionName: 'banners',
                  message: 'message',
                ),
                const Gap(15),
                _buildHorizontalList('Products', games, (game) {
                  return ProductsByGameScreen(gameName: game['name']!);
                }),
                const Gap(25),
                _buildHorizontalList('Accounts', accounts, (account) {
                  return GameAccountsScreen(gameName: account['name']!);
                }),
                const SizedBox(height: 190),
                _buildPaymentsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(
    String title,
    List<Map<String, String>> items,
    Widget Function(Map<String, String>) onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(
            title,
            style: const TextStyle(color: kwhite, fontSize: 20),
          ),
        ),
        const Gap(15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double itemWidth =
                  screenWidth < 600
                      ? 200
                      : screenWidth < 900
                      ? 180
                      : 240;
              double imageHeight =
                  screenWidth < 600
                      ? 180
                      : screenWidth < 900
                      ? 120
                      : 180;

              return SizedBox(
                height: imageHeight + 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => onTap(item)),
                        );
                      },
                      child: Container(
                        width: itemWidth,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              shadowColor: Colors.black45,
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                item['image']!,
                                width: double.infinity,
                                height: imageHeight,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                item['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: kwhite,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsRow() {
    return Container(
      color: const Color.fromARGB(255, 197, 197, 197),
      height: 45,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Gap(20),
          ClipOval(
            child: Image.asset('payments/golis.png', height: 60, width: 45),
          ),
          const Gap(20),
          ClipOval(
            child: Image.asset('payments/hormuud.png', height: 60, width: 45),
          ),
          const Gap(20),
          ClipOval(
            child: Image.asset('payments/somtel.jpg', height: 60, width: 45),
          ),
        ],
      ),
    );
  }

  Widget _buildBanners({
    required double height,
    required String collectionName,
    required String message,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      width: double.infinity,
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No banners found'));
          }

          final banners = snapshot.data!.docs;
          return CarouselSlider(
            options: CarouselOptions(
              height: height,
              autoPlay: false,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
            ),
            items:
                banners.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final message = data['message'] ?? '';
                  final imageUrl = data['image_url'] ?? '';
                  final colorHex = data['color'] ?? '';
                  final productId = data['product_id'];

                  Color bannerColor;
                  try {
                    bannerColor =
                        colorHex.isNotEmpty
                            ? Color(
                              int.parse(colorHex.replaceFirst('#', '0xff')),
                            )
                            : Colors.black;
                  } catch (_) {
                    bannerColor = Colors.black;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (productId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    ProductDetailsScreen(productId: productId),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: bannerColor.withOpacity(0.9),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Banner(
                          message: message,
                          location: BannerLocation.topStart,
                          color: Colors.red,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(Icons.error),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
