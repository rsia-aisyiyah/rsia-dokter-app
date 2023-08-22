import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    firebaseInit();
  }

  void firebaseInit() async {
    await Firebase.initializeApp();
    await FirebaseApi().initNotif(context);
    await FirebaseMessaging.instance.subscribeToTopic('dokter');
    SharedPreferences.getInstance().then((prefs) async {
      var spesialis = prefs.getString('spesialis')!.toLowerCase();
      if (spesialis.contains('kandungan')) {
        await FirebaseMessaging.instance.subscribeToTopic('kandungan');
      } else if (spesialis.contains('umum')) {
        await FirebaseMessaging.instance.subscribeToTopic('umum');
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
    return WillPopScope(
      onWillPop: () async {
        if (_selectedNavbar != 0) {
          setState(() {
            _selectedNavbar = 0;
          });
          return false; // Block the default back button behavior
        }
        return true; // Allow the default back button behavior
      },
      child: Scaffold(
        body: navigationItems[_selectedNavbar]['widget'] as Widget,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: accentColor,
          unselectedItemColor: textColor.withOpacity(0.5),
          currentIndex: _selectedNavbar,
          showUnselectedLabels: false,
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
