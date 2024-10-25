// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:rsiap_dokter/api/firebase_api.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _selectedNavbar = 0;
  final navigatorKey = GlobalKey<NavigatorState>();
  String spesialis = '';

  @override
  void initState() {
    super.initState();
    firebaseInit();

    checkForUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkForUpdate();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((updateInfo) {
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform immediate update
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              //App Update successful
            }
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          //Perform flexible update
          InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              //App Update successful
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        }
      }
    });
  }

  void firebaseInit() async {
    await FirebaseApi().initNotif(context);
    await FirebaseMessaging.instance.subscribeToTopic('dokter');

    SharedPreferences.getInstance().then((prefs) async {
      var kd_dokter = prefs.getString('sub')!;
      var spesialis = prefs.getString('spesialis')!.toLowerCase();
      
      await FirebaseMessaging.instance.subscribeToTopic("${kd_dokter.replaceAll('"', '')}");

      if (spesialis.contains('kandungan')) {
        await FirebaseMessaging.instance.subscribeToTopic('kandungan');
      } else if (spesialis.contains('umum')) {
        await FirebaseMessaging.instance.subscribeToTopic('umum');
      } else if (spesialis.contains('anak')) {
        await FirebaseMessaging.instance.subscribeToTopic('anak');
      } else if (spesialis.contains('radiologi')) {
        await FirebaseMessaging.instance.subscribeToTopic('radiologi');
      }
    });
  }

  void _changeSelectedNavBar(int index) {
    setState(() {
      _selectedNavbar = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedNavbar != 0,
      child: Scaffold(
        body: navigationItems[_selectedNavbar]['widget'] as Widget,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: accentColor,
          unselectedItemColor: textColor.withOpacity(0.5),
          currentIndex: _selectedNavbar,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          onTap: (index) {
            _changeSelectedNavBar(index);
          },
          items: navigationItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item['icon'] as IconData),
              label: item['label'] as String,
            );
          }).toList(),
        ),
      ),
    );
  }
}
