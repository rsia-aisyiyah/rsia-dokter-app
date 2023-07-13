import 'dart:convert';

import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';

import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/List/pasien.dart';
import 'package:rsiap_dokter/components/List/jadwal_operasi.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/components/others/stats_home.dart';
import 'package:rsiap_dokter/config/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  var _pasienNow = {};
  var _dokter = {};
  var _jadwalOperasi = {};

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

  Future<void> fetchAllData() async {
    List<Future> futures = [
      _getDokter(),
      _getPasienNow(),
      _getJadwalOperasiNow(),
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

  Future<void> _getPasienNow() async {
    var res = await Api().getData('/dokter/pasien/2023/06');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      setState(() {
        _pasienNow = body;
      });
    }
  }

  Future<void> _getJadwalOperasiNow() async {
    var res = await Api().getData('/dokter/jadwal/operasi/2023/06');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      setState(() {
        _jadwalOperasi = body;
      });
    }
  }

  List filterPasienRawatInap(List pasien) {
    List pasienRawatInap = [];
    for (var i = 0; i < pasien.length; i++) {
      if (pasien[i]['status_lanjut'] == 'Ranap') {
        pasienRawatInap.add(pasien[i]);
      }
    }
    return pasienRawatInap;
  }

  List filterPasienRawatJalan(List pasien) {
    List pasienRawatJalan = [];
    for (var i = 0; i < pasien.length; i++) {
      if (pasien[i]['status_lanjut'] == 'Ralan') {
        pasienRawatJalan.add(pasien[i]);
      }
    }
    return pasienRawatJalan;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingku(primaryColor);
    } else {
      return DefaultTabController(
        length: 3,
        child: DraggableHome(
          title: const Text("Draggable Home"),
          headerWidget: StatsHomeWidget(
            dokter: _dokter,
            pasienNow: _pasienNow,
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
            IntrinsicHeight(
              child: TabBar(
                isScrollable: true,
                labelColor: accentColorDark,
                indicatorColor: primaryColorDark,
                unselectedLabelColor: textColor.withOpacity(0.2),
                padding: const EdgeInsets.all(10),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: primaryColorDark.withOpacity(0.2),
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: fontWeightNormal,
                ),
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: fontWeightBold,
                ),
                tabs: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: const Tab(text: 'Rawat Inap'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: const Tab(text: 'Rawat Jalan'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: const Tab(text: 'Jadwal Operasi'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                children: [
                  CreatePasienList(
                    pasien: filterPasienRawatInap(
                      _pasienNow['data']['data'],
                    ),
                  ),
                  CreatePasienList(
                    pasien: filterPasienRawatJalan(
                      _pasienNow['data']['data'],
                    ),
                  ),
                  CreateJadwalOperasiList(
                    pasien: _jadwalOperasi['data']['data'],
                  ),
                ],
              ),
            )
          ],
          fullyStretchable: false,
          backgroundColor: Colors.white,
          appBarColor: primaryColorDark,
        ),
      );
    }
  }
}
