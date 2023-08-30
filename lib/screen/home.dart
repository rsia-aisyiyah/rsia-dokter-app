import 'dart:convert';

import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';

import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/List/jadwal_operasi.dart';
import 'package:rsiap_dokter/components/List/pasien_ralan.dart';
import 'package:rsiap_dokter/components/List/pasien_ranap.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/components/others/stats_home.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/box_message.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  int selectedTab = 0;

  List dataPasien = [];

  Map metrics = {};
  var _dokter = {};

  var strExpired = 0.35;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      fetchAllData().then((value) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  // ---------------------- Fetch Data

  Future<void> fetchAllData() async {
    List<Future> futures = [
      _getDokter(),
      _getMetricsToday(),
      // _getJadwalOperasiNow(),
    ];

    await Future.wait(futures);
  }

  Future<void> _getDokter() async {
    var res = await Api().getData('/dokter');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      if (mounted) {
        var STRExpired = monthBetween(DateTime.parse(
          body['data']['pegawai']['kualifikasi_staff']['tanggal_akhir_str'],
        ));

        setState(() {
          _dokter = body;
          strExpired = STRExpired;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _dokter = {};
        });
      }
    }
  }

  Future<void> _getMetricsToday() async {
    var res = await Api().getData('/pasien/metric/now');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      if (mounted) {
        setState(() {
          // _pasienNow = body;
          // dataPasien = body['data']['data'];
          metrics = body['data'];
        });
      }
    }
  }

  // ---------------------- End Fetch Data

  // ---------------------- Tab Home

  void _changeSelectedNavBar(int index) {
    if (mounted) {
      setState(() {
        selectedTab = index;
      });
    }
  }

  List tabsHome = [
    {
      "label": rawatInapText,
      "icon": Icons.close,
      "widget": const ListPasienRanap()
    },
    {
      "label": rawatJalanText,
      "icon": Icons.close,
      "widget": const ListPasienRalan()
    },
    {
      "label": jadwalOperasiText,
      "icon": Icons.close,
      "widget": const ListJadwalOperasi()
    },
  ];

  // ---------------------- End Tab Home

  double monthBetween(DateTime endDate) {
    var now = DateTime.now();
    var difference = endDate.difference(now).inDays;
    var month = difference / 30;
    return month;
  }

  @override
  Widget build(BuildContext context) {
    double ph = strExpired <= STRExpMin ? 0.385 : .35;
    double height = MediaQuery.of(context).size.height;

    double topWidgetHeight = (height.floorToDouble() * ph).floorToDouble(); // ganti 0.4 untuk mengatur tinggi top widget
    double initMax = (height.floorToDouble() - topWidgetHeight).floorToDouble();

    double percentageInitMax = ((initMax / height.floorToDouble()) * 100).floorToDouble();
    double percentageTopWidgetHeight =
        ((topWidgetHeight / height.floorToDouble()) * 100).floorToDouble();

    // percentage to decimal
    percentageInitMax = (percentageInitMax / 100);
    percentageTopWidgetHeight = (percentageTopWidgetHeight / 100);

    return isLoading ?  loadingku() : DefaultTabController(
      length: tabsHome.length,
      child: DraggableHome(
        title: Text(
          tabsHome[selectedTab]['label'] as String,
        ),
        headerExpandedHeight: percentageTopWidgetHeight,
        headerWidget: _dokter.isEmpty ? BoxMessage(
          title: "Data Dokter Tidak Ditemukan",
          body: "Data dokter tidak ditemukan, hal ini bisa terjadi karena data dokter belum diinputkan oleh admin. Silahkan hubungi admin untuk menginputkan data dokter.",
          backgroundColour: bgColor,
        ) : StatsHomeWidget(
          dokter: _dokter,
          metrics: metrics,
          onTap: _changeSelectedNavBar,
          widgetHeight: topWidgetHeight,
        ),
        body: [
          Row(
            children: [
              const Spacer(),
              Container(
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
            ],
          ),
          tabsHome[selectedTab]['widget'] as Widget,
        ],
        fullyStretchable: false,
        backgroundColor: Colors.white,
        appBarColor: primaryColor,
        bottomNavigationBar: Container(
          color: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: TabBar(
            onTap: _changeSelectedNavBar,
            labelColor: textWhite,
            indicatorColor: Colors.transparent,
            unselectedLabelColor: textColor.withOpacity(.5),
            tabs: tabsHome.map(
              (e) {
                return Tab(
                  child: Center(
                    child: Text(
                      e['label'] as String,
                      style: TextStyle(
                        fontSize: Helper.getFontSize(context, mobileCaption),
                        fontWeight: e['label'] == tabsHome[selectedTab]['label']
                              ? fontSemiBold
                              : fontNormal,
                        color: e['label'] == tabsHome[selectedTab]['label']
                          ? textWhite
                          : textColor.withOpacity(.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
