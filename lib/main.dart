import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/screen/menu.dart';
import 'package:rsiap_dokter/screen/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rsiap_dokter/screen/login.dart';
import 'package:rsiap_dokter/screen/index.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/msg.dart';

import 'api/request.dart';
import 'config/api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    await Future.delayed(Duration(seconds: 2));

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
    String token;
    var firebaseMessaging = await FirebaseMessaging.instance;
    token = (await firebaseMessaging.getToken())!;

    String url = "https://iid.googleapis.com/iid/info/" + token + "?details=true";
    var res = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer ${ApiConfig.fsk}",
    });

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      Map<String, dynamic> subscribedTopics = body['rel']['topics'];

      subscribedTopics.forEach((key, value) async {
        await Future.delayed(Duration(milliseconds: 10));
        await FirebaseMessaging.instance.unsubscribeFromTopic(key);
        debugPrint("Unsubscribed from topic: $key");
      });

      firebaseMessaging.deleteToken();
      await FirebaseMessaging.instance.deleteToken();

      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: checkToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Tampilkan widget loading ketika sedang menunggu hasil.
              return loadingku();
            } else if (snapshot.hasError) {
              // Handle error jika ada kesalahan.
              // return Text('Error: ${snapshot.error}');
              return Msg.error(context, 'Error: ${snapshot.error}');
            } else {
              // Redirect sesuai hasil pengecekan token.
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
