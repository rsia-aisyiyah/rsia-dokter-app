import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/login.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  void _logout() async {
    var res = await Api().postRequest('/auth/logout');
    var body = json.decode(res.body);

    if (body['success']) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('token');
        Msg.success(context, logoutSuccessMsg);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      });
    }
  }

  _getMe() async {
    var res = await Api().getData('/dokter');
    var body = json.decode(res.body);
    return body;
  }

  double monthBetween(DateTime endDate) {
    var now = DateTime.now();
    var difference = endDate.difference(now).inDays;
    var month = difference / 30;
    return month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: FutureBuilder(
          future: _getMe(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = json.decode(json.encode(snapshot.data));
              if (data['success']) {
                var STRExpired = monthBetween(DateTime.parse(
                  data['data']['pegawai']['kualifikasi_staff']
                      ['tanggal_akhir_str'],
                ));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Helper.greeting(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: fontWeightNormal,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data['data']['nm_dokter'],
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['data']['no_ijn_praktek'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: fontWeightNormal,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      padding: STRExpired <= STRExpMin
                          ? const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            )
                          : const EdgeInsets.all(0),
                      width: double.infinity,
                      decoration: STRExpired <= STRExpMin
                          ? BoxDecoration(
                              color: Colors.yellow[700],
                              borderRadius: BorderRadius.circular(5),
                            )
                          : null,
                      child: STRExpired <= STRExpMin
                          ? RichText(
                              text: TextSpan(
                                text: strExpiredIn,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        " ${STRExpired.toStringAsFixed(1)} Bulan",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                      fontWeight: fontWeightSemiBold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ". $strRenewText",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                text: "SIP : ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: data['data']['pegawai']
                                        ['kualifikasi_staff']['nomor_sip'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                      fontWeight: fontWeightSemiBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    SizedBox(height: STRExpired <= STRExpMin ? 10 : 15),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  _logout();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 20,
                                  ),
                                ),
                                child: Text(
                                  logoutText,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        failedToFetchDataMsg,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
            } else {
              return loadingku(primaryColor);
            }
          },
        ),
      ),
    );
  }
}
