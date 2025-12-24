import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kadin/screens/orders/delivery_product.dart';
import '../main.dart';

class PushNotificationService {
  static Future<void> init(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    // 🔹 Token save
    final token = await messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "fcmToken": token,
      }, SetOptions(merge: true));
    }

    // 🔹 App furan
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(message.notification?.title);
    });

    // 🔹 App background → notification la taabto
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleClick(message.data);
    });

    // 🔹 App completely closed
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleClick(initialMessage.data);
    }
  }

  // =========================
  // 🔔 HANDLE NOTIFICATION CLICK
  // =========================
  static void _handleClick(Map<String, dynamic> data) {
    if (data["type"] == "delivery") {
      final docId = data["docId"];
      final orderId = data["orderId"];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ProductDeliveryScreen(docId: docId, orderId: orderId),
        ),
      );
    }
  }
}
