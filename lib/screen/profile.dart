import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/blur.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/logout.dart';
import 'package:rsiap_dokter/utils/extensions/sensor.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/section_title.dart';
import 'package:rsiap_dokter/utils/table.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> dataTbl;
  late Map<String, dynamic> dataSTR;

  String dokter_nama = "";

  @override
  void initState() {
    super.initState();
  }

  Future _getMe() async {
    var res = await Api().getData('/dokter');
    var body = json.decode(res.body);
    return body;
  }

  setNamaDokter(nm) {
    setState(() {
      dokter_nama = nm;
    });
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
      "NIK": (detailDokter['pegawai']['nik'] as String).sensor(3),
      "Agama": detailDokter['agama'],
      "Tempat Lahir": detailDokter['tmp_lahir'],
      "Tanggal Lahir": (Helper.formatDate(detailDokter['tgl_lahir'])).sensor(8),
      "Alamat": (detailDokter['pegawai']['alamat'] as String).sensor(8),
      "Kota": (detailDokter['pegawai']['kota'] as String).sensor(4),
    };
  }

  void setSTR(dokter) {
    var k_staff = dokter['pegawai']['kualifikasi_staff_klinis'];
    dataSTR = {
      "STR": (k_staff['nomor_str'] as String).sensor(3),
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
            if (!snapshot.hasData) {
              return loadingku();
            } else {
              var data = json.decode(json.encode(snapshot.data));
              if (!data['success']) {
                return Center(
                  child: Text(
                    data['message'],
                    style: TextStyle(
                      color: warningColor,
                      fontSize: 18,
                      fontWeight: fontBold,
                    ),
                  ),
                );
              }

              setDataTbl(data['data']);
              setSTR(data['data']);
              var STRExpired = monthBetween(DateTime.parse(
                data['data']['pegawai']['kualifikasi_staff_klinis']['tanggal_akhir_str'],
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
                                        child: const Icon(Icons.image_not_supported_outlined),
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
                                        // const SizedBox(height: 5),
                                        // BlurWidget(
                                        //   child: Text(
                                        //     data['data']['pegawai']['kualifikasi_staff_klinis']['nomor_sip'],
                                        //     style: TextStyle(
                                        //       fontSize: 12,
                                        //       fontWeight: fontNormal,
                                        //       color: textWhite,
                                        //     ),
                                        //   ),
                                        // ),
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
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(100, 70, 0, 0),
                        items: [
                          PopupMenuItem(
                            child: InkWell(
                              // onTap: () => _logout(),
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogoutScreen(),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: fontMedium,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          // 3 dots icon
                          Icons.more_vert_outlined,
                          color: textWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              );
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
