import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/List/pasien.dart';
import 'package:rsiap_dokter/components/cards/card_stats.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/components/others/stats_home.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/helper.dart';

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
    var res = await Api().getData('/dokter/jadwal/operasi/now');
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
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
          child: isLoading
              ? loadingku(textColorLight)
              : Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        StatsHomeWidget(dokter: _dokter, pasienNow: _pasienNow),
                      ],
                    ),
                  ),
                )),
    );
  }
}
