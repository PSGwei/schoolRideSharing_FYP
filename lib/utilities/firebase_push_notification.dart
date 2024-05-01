import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseAPI {
  final androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Hight Importance Notification',
    importance: Importance.defaultImportance,
  );

  final localNotification = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    print("fcm token $token");
    initPushNotification();
    initLocalNotification();
  }

  Future initPushNotification() async {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              androidChannel.id, androidChannel.name,
              channelDescription: androidChannel.description,
              icon: '@drawable/ic_launcher'),
        ),
        payload: jsonEncode(
          message.toMap(),
        ),
      );
    });
  }

  Future initLocalNotification() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);
    await localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    final platform = localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(androidChannel);
  }
}
