import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/api.dart';
import 'package:rsiap_dokter/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<bool> doLogout() async {
    final prefs = await SharedPreferences.getInstance();

    var res = await Api().postRequest('/auth/logout');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        await prefs.clear();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future unsubscribeFromTopic() async {
    SharedPreferences.getInstance().then((prefs) async {
      var kd_dokter = prefs.getString('sub')!;
      var spesialis = prefs.getString('spesialis')!.toLowerCase();

      await FirebaseMessaging.instance.unsubscribeFromTopic("${kd_dokter.replaceAll('"', '')}");

      if (spesialis.contains('kandungan')) {
        await FirebaseMessaging.instance.unsubscribeFromTopic('kandungan');
      } else if (spesialis.contains('umum')) {
        await FirebaseMessaging.instance.unsubscribeFromTopic('umum');
      } else if (spesialis.contains('anak')) {
        await FirebaseMessaging.instance.unsubscribeFromTopic('anak');
      } else if (spesialis.contains('radiologi')) {
        await FirebaseMessaging.instance.unsubscribeFromTopic('radiologi');
      }
    });

    await FirebaseMessaging.instance.unsubscribeFromTopic('dokter');

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([unsubscribeFromTopic(), doLogout()]),
        builder: (context, snapshot) {
          // if 2 od  them finished
          if (snapshot.connectionState == ConnectionState.done) {
            // show loading 2 second then navigate to login
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            });

            return loadingku();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),

      //   body: FutureBuilder<bool>(
      //     future: doLogout(),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasData) {
      //         if (snapshot.data!) {
      //           print(snapshot.data);
      //           return const Center(
      //             child: CircularProgressIndicator(),
      //           );
      //         } else {
      //           return const Center(
      //             child: Text('Gagal Logout'),
      //           );
      //         }
      //       } else {
      //         return const Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       }
      //     },
      //   ),
    );
  }
}
