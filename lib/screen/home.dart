import 'dart:convert';

import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/components/others/stats_home.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/box_message.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  int selectedTab = 0;
  String spesialis = '';

  List dataPasien = [];

  Map metrics = {};
  var _dokter = {};

  var strExpired = 0.35;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        spesialis = prefs.getString('spesialis')!;
      });
    });

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
          body['data']['pegawai']['kualifikasi_staff_klinis']
              ['tanggal_akhir_str'],
        ));

        setState(() {
          _dokter = body;
          strExpired = STRExpired;
        });
      }
    } else {
      var body = json.decode(res.body);
      Msg.error(context, body['message']);

      if (mounted) {
        setState(() {
          _dokter = {};
        });
      }
    }
  }

  Future<void> _getMetricsToday() async {
    await Future.delayed(const Duration(seconds: 2));

    var url = spesialis.toLowerCase().contains('radiologi')
        ? '/pasien/metric/radiologi/now'
        : '/pasien/metric/now';
    
    var res = await Api().getData(url);

    // var res = spesialis.toLowerCase().contains('radiologi')
    //     ? await Api().getData('/pasien/metric/radiologi/now')
    //     : await Api().getData('/pasien/metric/now');

    if (res.statusCode == 200) {
      var body = json.decode(res.body);

      if (mounted) {
        setState(() {
          // _pasienNow = body;
          // dataPasien = body['data']['data'];
          metrics = body['data'];
        });
      }
    } else {
      var body = json.decode(res.body);
      Msg.error(context, body['message']);

      if (mounted) {
        setState(() {
          metrics = {};
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

    // ganti 0.4 untuk mengatur tinggi top widget
    double topWidgetHeight = (height.floorToDouble() * ph).floorToDouble();
    double initMax = (height.floorToDouble() - topWidgetHeight).floorToDouble();

    double percentageInitMax = ((initMax / height.floorToDouble()) * 100).floorToDouble();
    double percentageTopWidgetHeight = ((topWidgetHeight / height.floorToDouble()) * 100).floorToDouble();

    // percentage to decimal
    percentageInitMax = (percentageInitMax / 100);
    percentageTopWidgetHeight = (percentageTopWidgetHeight / 100);

    List filteredTabs = tabsHome.where((tab) {
      final showOn = tab['show_on'] as Set;
      return showOn.contains(spesialis.toLowerCase().replaceAll('"', ''));
    }).toList();

    if (isLoading) {
      return loadingku();
    } else {
      return renderHome(
        filteredTabs,
        percentageTopWidgetHeight,
        topWidgetHeight,
        context,
      );
    }
  }

  DraggableHome renderHomeRadiologi(
    List<dynamic> filteredTabs,
    double percentageTopWidgetHeight,
    double topWidgetHeight,
    BuildContext context,
  ) {
    return DraggableHome(
      leading: const Icon(Icons.arrow_back_ios),
      title: const Text("Pasien Radiologi"),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
      ],
      headerWidget: dokterStats(filteredTabs),
      headerBottomBar: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            color: Colors.white,
          ),
        ],
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
      ],
      fullyStretchable: true,
      backgroundColor: Colors.white,
      appBarColor: Colors.teal,
    );
  }

  DefaultTabController renderHome(
    List<dynamic> filteredTabs,
    double percentageTopWidgetHeight,
    double topWidgetHeight,
    BuildContext context,
  ) {
    return DefaultTabController(
      length: filteredTabs.length,
      child: DraggableHome(
        title: Text(
          filteredTabs[selectedTab]['label'] as String,
        ),
        headerExpandedHeight: percentageTopWidgetHeight,
        headerWidget: dokterStats(filteredTabs),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade100,
              width: 3,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          width: 55,
          height: 55,
          child: FloatingActionButton(
            backgroundColor: primaryColor,
            elevation: 0,
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchAllData().then((value) {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              });
            },
            child: const Icon(Icons.refresh),
          ),
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
          filteredTabs[selectedTab]['widget'] as Widget,
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
            tabs: filteredTabs.map((e) {
              return Tab(
                child: Center(
                  child: Text(
                    e['label'] as String,
                    style: TextStyle(
                      fontSize: Helper.getFontSize(context, mobileCaption),
                      fontWeight: getFontWeight(e, filteredTabs),
                      color: getFontColor(e, filteredTabs),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  StatelessWidget dokterStats(
    List<dynamic> filteredTabs,
  ) {
    if (_dokter.isEmpty) {
      return BoxMessage(
        title: "Data Dokter Tidak Ditemukan",
        body:
            "Data dokter tidak ditemukan, hal ini bisa terjadi karena data dokter belum diinputkan oleh admin. Silahkan hubungi admin untuk menginputkan data dokter.",
        backgroundColour: bgColor,
      );
    } else {
      return StatsHomeWidget(
        dokter: _dokter,
        metrics: metrics,
        onTap: _changeSelectedNavBar,
        filteredTabs: filteredTabs,
      );
    }
  }

  Color getFontColor(e, List<dynamic> filteredTabs) {
    return e['label'] == filteredTabs[selectedTab]['label']
        ? textWhite
        : textColor.withOpacity(.5);
  }

  FontWeight getFontWeight(e, List<dynamic> filteredTabs) {
    return e['label'] == filteredTabs[selectedTab]['label']
        ? fontSemiBold
        : fontNormal;
  }
}
