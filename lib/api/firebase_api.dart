import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rsiap_dokter/screen/detail/pasien.dart';
import 'package:rsiap_dokter/screen/detail/radiologi.dart';
import 'package:rsiap_dokter/screen/detail/resume.dart';
import 'package:rsiap_dokter/screen/index.dart';

late BuildContext ctx;

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final _localNotification = FlutterLocalNotificationsPlugin();
final _androidChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications',
  importance: Importance.defaultImportance,
);

Future<void> handleNotificationAction(String action, Map<String, dynamic> data) async {
  if (action == 'resume') {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) => ResumePasienRanap(
          noRawat: data['no_rawat'],
          kategori: "Ranap",
        ),
      ),
    );
  } else if (action == 'detail') {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) => DetailPasien(
          kategori: "Ranap",
          noRawat: data['no_rawat'],
        ),
      ),
    );
  } else if (action == 'radiologi') {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) => DetailRadiologi(
          penjab: data['penjab'] ?? "UMUM",
          noRawat: data['no_rawat'],
          tanggal: data['tanggal'],
          jam: data['jam'],
        ),
      ),
    );
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  final data = message.data;
  final action = data['action'];
  if (action != null) {
    handleNotificationAction(action, data);
  } else {
    Navigator.of(ctx).push(
      MaterialPageRoute(builder: (context) => IndexScreen()),
    );
  }
}

Future<void> handleMessage(RemoteMessage message) async {
  final data = message.data;
  final action = data['action'];
  if (action != null) {
    handleNotificationAction(action, data);
  } else {
    Navigator.of(ctx).push(
      MaterialPageRoute(builder: (context) => IndexScreen()),
    );
  }
}

Future initLocalNotification() async {
  const iOS = DarwinInitializationSettings();
  const android = AndroidInitializationSettings('@drawable/launcher_icon');
  final settings = InitializationSettings(iOS: iOS, android: android);

  await _localNotification.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) {
      final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
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

  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotification.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: _androidChannel.importance,
          icon: "@drawable/launcher_icon",
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
  });
}

class FirebaseApi {
  Future<void> initNotif(BuildContext context) async {
    ctx = context;
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    await FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(true);
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
    initPushNotification();
    initLocalNotification();
  }
}
