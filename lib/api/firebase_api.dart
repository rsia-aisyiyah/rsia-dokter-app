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
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final _androidChannel = AndroidNotificationChannel(
  'high_importance_channel', // ID channel
  'High Importance Notifications', // Nama channel
  description: 'This channel is used for important notifications',
  importance: Importance.high, // Ubah ke Importance.high
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

Future<void> onDidReceiveLocalNotification(NotificationResponse response) async {
  handleMessage(RemoteMessage.fromMap(jsonDecode(response.payload!)));
}

Future initLocalNotification() async {
  const iOS = DarwinInitializationSettings();
  const android = AndroidInitializationSettings('@drawable/launcher_icon');
  final settings = InitializationSettings(iOS: iOS, android: android);

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
    onDidReceiveBackgroundNotificationResponse: onDidReceiveLocalNotification,
  );

  // Registrasikan channel untuk Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
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

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high, // Pastikan Importance tinggi
          priority: Priority.high, // Pastikan priority tinggi
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
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(true);
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
    initPushNotification();
    initLocalNotification();
  }
}
