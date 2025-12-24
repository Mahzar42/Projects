import 'package:admin/Product%20Manage/product_account_screen.dart';
import 'package:admin/Product%20Manage/product_manage_screen.dart';
import 'package:admin/drawer/analytics_screen.dart';
import 'package:admin/drawer/customers_screen.dart';
import 'package:admin/drawer/history_screen.dart';
import 'package:admin/drawer/offer_screen.dart';
import 'package:admin/drawer/sales_acc_screen.dart';
import 'package:admin/drawer/sales_items_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notification = message.notification!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification.title}: ${notification.body}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.deepPurple.shade400,
          ),
        );
      }
    });
  }

  Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    // Halkan waa FCM POST request ama package aad isticmaaleyso
    // Tusaale: firebase_messaging
    await FirebaseMessaging.instance.sendMessage(
      to: token,
      data: {'title': title, 'body': body},
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1E44), // Dark navy background
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Admin - Maamulka Lacagaha',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.1,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF283593),
              ], // purple to indigo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
        shadowColor: Colors.deepPurpleAccent,
      ),
      body:
          user == null
              ? const Center(
                child: Text(
                  'User not logged in',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      "💳  ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),

                  // Payments Stream
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('payments')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepPurpleAccent,
                          ),
                        );
                      }

                      final payments =
                          snapshot.data!.docs.where((doc) {
                            final data = doc.data()! as Map<String, dynamic>;
                            final paymentStatus =
                                data['payment_status'] ?? 'Awaiting';
                            final deliveryStatus =
                                data['delivery_status'] ?? 'Pending';

                            return paymentStatus == 'Awaiting' ||
                                (paymentStatus == 'Confirmed' &&
                                    deliveryStatus != 'Done');
                          }).toList();

                      if (payments.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Ma jiro lacag la xiriira oo la helay.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children:
                            payments.map((payment) {
                              final data =
                                  payment.data()! as Map<String, dynamic>;
                              final paymentStatus =
                                  data['payment_status'] ?? 'Awaiting';
                              final deliveryStatus =
                                  data['delivery_status'] ?? 'Pending';
                              final deliveryOptions = [
                                'Waiting',
                                'Done',
                                'Cancelled',
                              ];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    24,
                                  ), // ⬅️ wareeg qurux badan
                                ),
                                elevation: 12, // ⬅️ qoto dheer
                                shadowColor: Colors.black.withOpacity(0.4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4A148C), // purple deep
                                        Color(0xFF1A237E), // indigo
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor:
                                          Colors
                                              .transparent, // ⬅️ ExpansionTile line ka tir
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      iconColor: Colors.white,
                                      collapsedIconColor: Colors.white70,
                                      title: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.white12,
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Row(
                                              children: [
                                                _buildDetailText(
                                                  'Order Id ',
                                                  data['order_id'],
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  splashRadius: 18,
                                                  icon: const Icon(
                                                    Icons.copy,
                                                    color: Colors.white70,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text:
                                                            data['id_game'] ??
                                                            '',
                                                      ),
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'ID Game copied to clipboard',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.phone_android,
                                              color: Colors.white60,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                '${data['phone']} • ${data['payment_method']}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 14,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildDetailText(
                                                'Player Game',
                                                data['player_name'],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  _buildDetailText(
                                                    'ID Game',
                                                    data['id_game'],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    splashRadius: 18,
                                                    icon: const Icon(
                                                      Icons.copy,
                                                      color: Colors.white70,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                        ClipboardData(
                                                          text:
                                                              data['id_game'] ??
                                                              '',
                                                        ),
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'ID Game copied to clipboard',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 6),
                                              _buildDetailText(
                                                'Game Type',
                                                data['name'],
                                              ),
                                              SizedBox(height: 6),
                                              _buildDetailText(
                                                'Lacag',
                                                '\$${data['price']}',
                                              ),
                                              SizedBox(height: 6),
                                              _buildDetailText(
                                                'Telefoon',
                                                data['phone'],
                                              ),
                                              SizedBox(height: 6),
                                              _buildDetailText(
                                                'Waqtiga',
                                                data['timestamp'] is Timestamp
                                                    ? (data['timestamp']
                                                            as Timestamp)
                                                        .toDate()
                                                        .toString()
                                                    : 'N/A',
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  // STATUS
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white10,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Xaaladda Bixinta: $paymentStatus',
                                                      style: TextStyle(
                                                        color:
                                                            paymentStatus ==
                                                                    'Confirmed'
                                                                ? Colors
                                                                    .greenAccent
                                                                : paymentStatus ==
                                                                    'Failed'
                                                                ? Colors
                                                                    .redAccent
                                                                : Colors
                                                                    .orangeAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),

                                                  if (paymentStatus ==
                                                      'Awaiting') ...[
                                                    const SizedBox(
                                                      width: 12,
                                                    ), // ⬅️ WIDTH (ma aha height)

                                                    _styledTextButton(
                                                      label: '✅ Xaqiiji',
                                                      color: Colors.greenAccent,
                                                      onPressed: () async {
                                                        // 1️⃣ Update payment status
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                              'payments',
                                                            )
                                                            .doc(payment.id)
                                                            .update({
                                                              'payment_status':
                                                                  'Confirmed',
                                                            });

                                                        // 2️⃣ Dir push notification
                                                        final userToken =
                                                            data['user_fcm_token'];
                                                        if (userToken != null) {
                                                          await sendPushNotification(
                                                            token: userToken,
                                                            title:
                                                                "Payment Confirmed",
                                                            body:
                                                                "Asc, lacagtaada waa la xaqiijiyay. Order ID: ${data['order_id']}",
                                                          );
                                                        }

                                                        // 3️⃣ Kaydi comment Somali
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                              'payments',
                                                            )
                                                            .doc(payment.id)
                                                            .update({
                                                              'admin_comment':
                                                                  "Lacagta waa la xaqiijiyay. ✅",
                                                            });
                                                      },
                                                    ),

                                                    const SizedBox(width: 8),

                                                    _styledTextButton(
                                                      label: '❌ Diid',
                                                      color: Colors.redAccent,
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                              'payments',
                                                            )
                                                            .doc(payment.id)
                                                            .update({
                                                              'payment_status':
                                                                  'Failed',
                                                            });
                                                      },
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Xaaladda Gaarsiinta: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                  DropdownButton<String>(
                                                    dropdownColor: const Color(
                                                      0xFF3A0CA3,
                                                    ),
                                                    value:
                                                        deliveryOptions.contains(
                                                              deliveryStatus,
                                                            )
                                                            ? deliveryStatus
                                                            : 'Done',
                                                    items:
                                                        deliveryOptions.map((
                                                          status,
                                                        ) {
                                                          return DropdownMenuItem(
                                                            value: status,
                                                            child: Text(
                                                              status,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                    onChanged: (newStatus) {
                                                      if (newStatus != null) {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                              'payments',
                                                            )
                                                            .doc(payment.id)
                                                            .update({
                                                              'delivery_status':
                                                                  newStatus,
                                                            });
                                                        // ScaffoldMessenger.of(context).showSnackBar(
                                                        //   SnackBar(
                                                        //     content: Text(
                                                        //         'Xaaladda gaarsiinta waa loo beddelay: $newStatus'),
                                                        //     backgroundColor: Colors.deepPurple,
                                                        //   ),
                                                        // );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),

                  const Divider(
                    height: 40,
                    thickness: 2,
                    color: Colors.deepPurpleAccent,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      "📋 Accounts Sell",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),

                  //  Accounts Sell Stream
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('AccountsSell')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepPurpleAccent,
                          ),
                        );
                      }

                      final payments =
                          snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final paymentStatus =
                                data['payment_status'] ?? 'Pending';
                            final deliveryStatus =
                                data['delivery_status'] ?? 'Pending';

                            return paymentStatus == 'Pending' ||
                                (paymentStatus == 'Confirmed' &&
                                    deliveryStatus != 'Done');
                          }).toList();

                      if (payments.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Ma jiro lacag la xiriira oo la  helay.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children:
                            payments.map((payment) {
                              final data =
                                  payment.data() as Map<String, dynamic>;
                              final paymentStatus =
                                  data['payment_status'] ?? 'Pending';
                              final deliveryStatus =
                                  data['delivery_status'] ?? 'Pending';
                              final deliveryOptions = [
                                'Done',
                                'Shipped',
                                'Delivered',
                                'Cancelled',
                              ];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                                shadowColor: Colors.deepPurpleAccent
                                    .withOpacity(0.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF3A0CA3),
                                        Color(0xFF720026),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ExpansionTile(
                                    iconColor: Colors.white,
                                    collapsedIconColor: Colors.white70,
                                    title: Row(
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            data['name'] ?? "Magac la’aan",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${data['phone'] ?? "Telefoon la’aan"} - ${data['payment_method'] ?? "Hab la’aan"}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white70,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildDetailText(
                                              'Order ID',
                                              data['order_id'],
                                            ),
                                            _buildDetailText(
                                              'Mulkiilaha',
                                              data['game_name'],
                                            ),
                                            _buildDetailText(
                                              'Account Title',
                                              data['account_title'],
                                            ),
                                            _buildDetailText(
                                              'Level',
                                              data['level'],
                                            ),
                                            buildStatForPopulationStrength(
                                              data,
                                            ),
                                            _buildDetailText(
                                              'Qiimaha',
                                              '\$${data['price']}',
                                            ),
                                            _buildDetailText(
                                              'Waqtiga',
                                              data['timestamp'] is Timestamp
                                                  ? (data['timestamp']
                                                          as Timestamp)
                                                      .toDate()
                                                      .toString()
                                                  : "N/A",
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white10,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Xaaladda Bixinta: $paymentStatus',
                                                    style: TextStyle(
                                                      color:
                                                          paymentStatus ==
                                                                  'Confirmed'
                                                              ? Colors
                                                                  .greenAccent
                                                              : paymentStatus ==
                                                                  'Failed'
                                                              ? Colors.redAccent
                                                              : Colors
                                                                  .orangeAccent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (paymentStatus == 'Pending') ...[
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  _styledTextButton(
                                                    label: '✅ Xaqiiji',
                                                    color: Colors.greenAccent,
                                                    onPressed: () {
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                            'AccountsSell',
                                                          )
                                                          .doc(payment.id)
                                                          .update({
                                                            'payment_status':
                                                                'Confirmed',
                                                          });
                                                      // ScaffoldMessenger.of(context).showSnackBar(
                                                      //   const SnackBar(
                                                      //     content: Text('Lacagta waa la xaqiijiyay'),
                                                      //     backgroundColor: Colors.green,
                                                      //   ),
                                                      // );
                                                    },
                                                  ),
                                                  _styledTextButton(
                                                    label: '❌ Diid',
                                                    color: Colors.redAccent,
                                                    onPressed: () {
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                            'AccountsSell',
                                                          )
                                                          .doc(payment.id)
                                                          .update({
                                                            'payment_status':
                                                                'Failed',
                                                          });
                                                      // ScaffoldMessenger.of(context).showSnackBar(
                                                      //   const SnackBar(
                                                      //     content: Text('Lacagta waa la diiday'),
                                                      //     backgroundColor: Colors.red,
                                                      //   ),
                                                      // );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Xaaladda Gaarsiinta: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                DropdownButton<String>(
                                                  dropdownColor: const Color(
                                                    0xFF3A0CA3,
                                                  ),
                                                  value:
                                                      deliveryOptions.contains(
                                                            deliveryStatus,
                                                          )
                                                          ? deliveryStatus
                                                          : 'Done',
                                                  items:
                                                      deliveryOptions.map((
                                                        status,
                                                      ) {
                                                        return DropdownMenuItem(
                                                          value: status,
                                                          child: Text(
                                                            status,
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                  onChanged: (newStatus) async {
                                                    if (newStatus != null) {
                                                      // Update Firestore
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                            'payments',
                                                          )
                                                          .doc(payment.id)
                                                          .update({
                                                            'delivery_status':
                                                                newStatus,
                                                          });

                                                      // Push Notification
                                                      final userToken =
                                                          data['user_fcm_token'];
                                                      if (userToken != null) {
                                                        String bodyMessage = "";
                                                        if (newStatus ==
                                                            "Done") {
                                                          bodyMessage =
                                                              "Asc, adeeggaaga waa la dhammeeyay. Order ID: ${data['order_id']}";
                                                        } else if (newStatus ==
                                                            "Cancelled") {
                                                          bodyMessage =
                                                              "Asc, adeeggaaga waa la joojiyay. Order ID: ${data['order_id']}";
                                                        } else {
                                                          bodyMessage =
                                                              "Asc, adeeggaaga waa la cusbooneysiiyay: $newStatus. Order ID: ${data['order_id']}";
                                                        }

                                                        await sendPushNotification(
                                                          token: userToken,
                                                          title:
                                                              "Delivery Update",
                                                          body: bodyMessage,
                                                        );
                                                      }

                                                      // Comment Somali
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                            'payments',
                                                          )
                                                          .doc(payment.id)
                                                          .update({
                                                            'admin_comment':
                                                                "Xaaladda gaarsiinta waa la beddelay: $newStatus",
                                                          });
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ],
              ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const ProductManageScreen(),
      //       ),
      //     );
      //   },
      //   backgroundColor: Colors.deepPurpleAccent,
      //   child: const Icon(Icons.add, color: Colors.white),
      //   elevation: 6,
      //   tooltip: 'Add Product',
      // ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF283593),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child:
                  user == null
                      ? const Center(
                        child: Text(
                          'User not logged in',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                      : FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              !snapshot.data!.exists) {
                            return const Center(
                              child: Text(
                                'User data error',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          if (data == null) {
                            return const Center(
                              child: Text(
                                'No data',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white24,
                                backgroundImage:
                                    data['image'] != null &&
                                            data['image'].toString().isNotEmpty
                                        ? NetworkImage(data['image'])
                                        : const AssetImage(
                                              'assets/images/default_avatar.png',
                                            )
                                            as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['email'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['phone'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
            ),

            _buildDrawerItem(Icons.add_box, 'Maamul Alaabta', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductManageScreen()),
              );
            }),
            _buildDrawerItem(Icons.add_box, 'Maamul Accounts', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductAccountScreen()),
              );
            }),
            _buildDrawerItem(Icons.auto_graph, 'Warbixinada iib ka Items', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesScreen()),
              );
            }),
            _buildDrawerItem(
              Icons.auto_graph,
              'Warbixinada iib ka Accounts',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesAccScreen()),
                );
              },
            ),
            _buildDrawerItem(Icons.local_offer, 'Dallacsiin & Xayeysiin', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OffersScreen()),
              );
            }),
            _buildDrawerItem(Icons.analytics, 'Falanqayn', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsGraphScreen()),
              );
            }),
            _buildDrawerItem(Icons.people, 'Macaamiisha', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersScreen()),
              );
            }),
            _buildDrawerItem(Icons.history, 'Taariikhda Amarada', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            }),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text(
                'Ka Bax',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: ${value ?? "N/A"}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _styledTextButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.85),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.deepPurple.shade300,
      splashColor: Colors.deepPurple.shade300,
    );
  }

  Widget buildStatForPopulationStrength(Map<String, dynamic> data) {
    // Halkan hubi in key-ga "Population " (oo leh space) iyo "Population" la kala socdo
    final pop = data['Population'] ?? data['Population '];
    final strength = data['Strength'];
    final another = data['AnotherKey'];

    if (pop != null) {
      return _buildDetailText("Level", pop);
    } else if (strength != null) {
      return _buildDetailText("C.S", strength);
    } else if (another != null) {
      return _buildDetailText("Other", another);
    } else {
      return _buildDetailText("N/A", "No data");
    }
  }
}
