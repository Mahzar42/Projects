import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kadin/main.dart';
import 'package:kadin/screens/orders/delivery_product.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Codsi ogolaansho (Android 13+)
    await _fcm.requestPermission();

    // Local notification settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidInit);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _handleClick(response.payload);
      },
    );

    // Faylkan wuxuu mas'uul ka yahay:
    // 1. Qaadashada token
    // 2. Dhageysiga notification
    // 3. Furista screen marka la taabto

    // Qaado FCM Token
    String? token = await _fcm.getToken();
    print("FCM TOKEN: $token");

    // Notification marka app-ku furan yahay
    FirebaseMessaging.onMessage.listen((message) {
      _show(message);
    });

    // Marka notification la taabto (background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigate(message.data);
    });

    // Marka app-ka xirnaa la furo
    RemoteMessage? initial =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _navigate(initial.data);
    }
  }

  // Show notification
  void _show(RemoteMessage message) {
    _local.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default',
          'General',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // Marka user taabto notification
  void _handleClick(String? payload) {
    if (payload == null) return;
    final data = jsonDecode(payload);
    _navigate(data);
  }

  // Go'aami screen-ka la furayo
  void _navigate(Map data) {
    final screen = data['screen'];

    if (screen == 'payment') {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder:
              (context) =>
                  ProductDeliveryScreen(docId: docId, orderId: orderId),
        ),
      );
    }

    if (screen == 'delivery') {
      navigatorKey.currentState!.pushNamed('/deliveryDetails', arguments: data);
    }
  }
}
