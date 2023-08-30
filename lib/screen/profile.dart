import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:rsiap_dokter/utils/section_title.dart';
import 'package:rsiap_dokter/utils/table.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> dataTbl;
  late Map<String, dynamic> dataSTR;

  @override
  void initState() {
    super.initState();
  }

  void _logout() async {
    var res = await Api().postRequest('/auth/logout');
    var body = json.decode(res.body);

    if (body['success']) {
      await FirebaseMessaging.instance.unsubscribeFromTopic('dokter');
      SharedPreferences.getInstance().then((prefs) async {
        var spesialis = prefs.getString('spesialis')!.toLowerCase();
        if (spesialis.contains('kandungan')) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('kandungan');
        } else if (spesialis.contains('umum')) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('umum');
        }
      });

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
      "Spesialis": detailDokter['spesialis']['nm_sps'],
      "Jabatan": detailDokter['pegawai']['jbtn'],
      "NIK": detailDokter['pegawai']['nik'],
      "Agama": detailDokter['agama'],
      "Tempat Lahir": detailDokter['tmp_lahir'],
      "Tanggal Lahir": Helper.formatDate(detailDokter['tgl_lahir']),
      "Alamat": detailDokter['pegawai']['alamat'],
      "Kota": detailDokter['pegawai']['kota'],
    };
  }

  void setSTR(dokter) {
    var k_staff = dokter['pegawai']['kualifikasi_staff_klinis'];
    dataSTR = {
      "STR": k_staff['nomor_str'],
      "Tanggal STR": Helper.formatDate(k_staff['tanggal_str']),
      "Akhir STR": Helper.formatDate(k_staff['tanggal_akhir_str']),
      "Kategori Profesi": k_staff['kategori_profesi'],
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
                setSTR(data['data']);
                var STRExpired = monthBetween(DateTime.parse(
                  data['data']['pegawai']['kualifikasi_staff_klinis']
                      ['tanggal_akhir_str'],
                ));
                return Stack(
                  children: [
                    Column(
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
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: textWhite,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CachedNetworkImage(
                                        imageUrl: photoUrl + data['data']['pegawai']['photo'].toString(),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        placeholder: (context, url) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Flexible(
                                    flex: 2,
                                    fit: FlexFit.tight,
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                          Text(
                                            data['data']['nm_dokter'],
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontSize: mobileSubTitle,
                                              fontWeight: fontBold,
                                              color: textWhite,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            data['data']['pegawai']
                                                    ['kualifikasi_staff_klinis']
                                                ['nomor_sip'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: fontNormal,
                                              color: textWhite,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  const SectionTitle(title: "Detail Dokter"),
                                  const SizedBox(height: 5),
                                  GenTable(data: dataTbl),
                                  const SizedBox(height: 20),
                                  const SectionTitle(title: "Detail STR"),
                                  const SizedBox(height: 5),
                                  GenTable(data: dataSTR),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // positioned logout icon on top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => _logout(),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            Icons.logout,
                            color: textWhite,
                          ),
                        ),
                      )
                      // child: IconButton(
                      //   onPressed: () {
                      //     _logout();
                      //   },
                      //   icon: Icon(
                      //     Icons.logout,
                      //     color: textWhite,
                      //   ),
                      // ),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: fontBold,
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
