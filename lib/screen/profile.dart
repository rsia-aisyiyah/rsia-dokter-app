import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/login.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:rsiap_dokter/utils/table.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> dataTbl;

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

  void setDataTbl(detailDokter) {
    dataTbl = {
      "Jabatan": detailDokter['pegawai']['jbtn'],
      "NIK": detailDokter['pegawai']['nik'],
      "Agama": detailDokter['agama'],
      "STR": detailDokter['pegawai']['kualifikasi_staff']['nomor_str'],
      "Tanggal STR": Helper.formatDate(
        detailDokter['pegawai']['kualifikasi_staff']['tanggal_str'],
      ),
      "Akhir STR": Helper.formatDate(
        detailDokter['pegawai']['kualifikasi_staff']['tanggal_akhir_str'],
      ),
      "Tempat Lahir": detailDokter['tmp_lahir'],
      "Tanggal Lahir": detailDokter['tgl_lahir'],
      "Alamat": detailDokter['pegawai']['alamat'],
      "Kota": detailDokter['pegawai']['kota'],
    };
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
                setDataTbl(data['data']);
                var STRExpired = monthBetween(DateTime.parse(
                  data['data']['pegawai']['kualifikasi_staff']
                      ['tanggal_akhir_str'],
                ));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(
                                  photoUrl + data['data']['pegawai']['photo'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Helper.greeting(),
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: fontNormal,
                                        color: textWhite,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      child: Text(
                                        data['data']['nm_dokter'],
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: textWhite,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          _STRCheck(STRExpired, data),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgWhite,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(50),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: textColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              GenTable(data: dataTbl),
                              const Spacer(),
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
              return loadingku();
            }
          },
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container _STRCheck(double STRExpired, data) {
    return Container(
      margin: EdgeInsets.only(top: STRExpired <= STRExpMin ? 20 : 0),
      padding: STRExpired <= STRExpMin
          ? const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            )
          : const EdgeInsets.all(0),
      width: double.infinity,
      decoration: STRExpired <= STRExpMin
          ? BoxDecoration(
              color: warningColor,
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
                    text: " ${STRExpired.toStringAsFixed(1)} $labelBulan",
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: fontSemiBold,
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
          : const SizedBox(),
    );
  }
}
