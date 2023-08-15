import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final navigtorKey = GlobalKey<NavigatorState>();
final _androidChannel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance);
final _localNotification = FlutterLocalNotificationsPlugin();

void handleMessage(RemoteMessage? message) {
  if (message == null) return;
  
  print('Message data : ${message.data}');
  print('Title : ' + message.notification!.title!);
  print('Body : ' + message.notification!.body!);

  // TODO : handle message to open screen
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Message data : ${message.data}');
  print('Title : ' + message.notification!.title!);
  print('Body : ' + message.notification!.body!);

  // TODO : handle message to open screen
}

Future initLocalNotification() async {
  const iOS = DarwinInitializationSettings();
  const android = AndroidInitializationSettings('@drawable/launcher_icon');

  final settings = InitializationSettings(iOS: iOS, android: android);

  await _localNotification.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) {
      final message = RemoteMessage.fromMap(
        details.payload as Map<String, dynamic>,
      );
      handleMessage(message);
    },
  );

  final platform = _localNotification.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()!;
  platform.createNotificationChannel(_androidChannel);
}

Future initPushNotification() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotification.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
            _androidChannel.id, _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: _androidChannel.importance,
            icon: "@drawable/launcher_icon"),
      ),
      payload: jsonEncode(message.toMap()),
    );
  });
}

class FirebaseApi {
  Future<void> initNotif() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
    initPushNotification();
    initLocalNotification();
  }
}
