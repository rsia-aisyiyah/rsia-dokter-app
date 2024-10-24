import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/screen/menu.dart';
import 'package:rsiap_dokter/screen/profile.dart';
import 'package:rsiap_dokter/screen/login.dart';
import 'package:rsiap_dokter/screen/index.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/msg.dart';

import 'api/request.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('id_ID', null).then(
    (_) => runApp(
      const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: SplashScreen(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/index': (context) => const IndexScreen(),
        '/manu': (context) => const MenuPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await Future.delayed(Duration(seconds: 1));

    if (token != null) {
      final res = await Api().postRequest('/auth/me');

      if (res.statusCode == 200) {
        return true; // Token valid, arahkan ke halaman indeks.
      }
    }

    // unsubscribe from topics
    await unsubscribeFromTopic();

    return false; // Tidak ada token atau request code bukan 200, arahkan ke halaman login.
  }

  Future unsubscribeFromTopic() async {
    SharedPreferences.getInstance().then((prefs) async {
      var kd_dokter = prefs.getString('sub');
      var spesialis = prefs.getString('spesialis');

      if (kd_dokter != null) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(kd_dokter);
      }

      if (spesialis != null) {
        if (spesialis.contains('kandungan')) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('kandungan');
        } else if (spesialis.contains('umum')) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('umum');
        } else if (spesialis.contains('anak')) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('anak');
        } else if (spesialis.contains('radiologi')) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('radiologi');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: checkToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadingku();
            } else if (snapshot.hasError) {
              return Msg.error(context, 'Unauthorized, please login again.');
            } else {
              if (snapshot.data == true) {
                return IndexScreen();
              } else {
                return LoginScreen();
              }
            }
          },
        ),
      ),
    );
  }
}
