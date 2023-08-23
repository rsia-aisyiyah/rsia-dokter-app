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
import 'package:rsiap_dokter/config/strings.dart';
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

  var _dokter = {};

  List dataPasien = [];

  Map metrics = {};

  @override
  void initState() {
    super.initState();
    fetchAllData().then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
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
      setState(() {
        _dokter = body;
      });
    }
  }

  Future<void> _getMetricsToday() async {
    var res = await Api().getData('/dokter/pasien/metric/now');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      setState(() {
        // _pasienNow = body;
        // dataPasien = body['data']['data'];
        metrics = body['data'];
      });
    }
  }

  // ---------------------- End Fetch Data

  // ---------------------- Tab Home

  void _changeSelectedNavBar(int index) {
    setState(() {
      selectedTab = index;
    });
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

  @override
  Widget build(BuildContext context) {
    // print(_dokter);
    if (isLoading) {
      return loadingku();
    } else {
      return DefaultTabController(
        length: tabsHome.length,
        child: DraggableHome(
          title: Text(
            tabsHome[selectedTab]['label'] as String,
          ),
          headerExpandedHeight: 0.4, //TODO : biar tidak nabark header wiget
          headerWidget: StatsHomeWidget(
              dokter: _dokter, metrics: metrics, onTap: _changeSelectedNavBar
              // pasienNow: dataPasien,
              // totalHariIni: _pasienNow['data']['total'],
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
                          fontWeight:
                              e['label'] == tabsHome[selectedTab]['label']
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
}
