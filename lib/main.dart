import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rsiap_dokter/config/strings.dart';

import 'package:rsiap_dokter/screen/login.dart';
import 'package:rsiap_dokter/screen/index.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/request.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null)
      .then((_) => runApp(const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: CheckAuth(),
      ),
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    _checkIsLoggedin();
  }

  void _checkIsLoggedin() {
    SharedPreferences.getInstance().then((prefs) {
      var token = prefs.getString('token');
      if (token != null) {
        Api().postRequest('/auth/me').then((res) {
          if (res.statusCode == 200) {
            if (mounted) {
              setState(() {
                isAuth = true;
              });
            }
          } else {
            if (mounted) {
              Msg.error(context, sessionExpiredMsg);
              setState(() {
                isAuth = false;
              });
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
      child = const IndexScreen();
    } else {
      child = const LoginScreen();
    }

    return child;
  }
}
