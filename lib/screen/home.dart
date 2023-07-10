import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/List/pasien.dart';
import 'package:rsiap_dokter/components/cards/card_stats.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchAllData() async {
    List<Future> futures = [
      _getDokter(),
      _getPasienNow(),
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

  // filter pasien rawat inap
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
    var heightDragsheet = MediaQuery.of(context).size.height *
        0.6 /
        MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: FutureBuilder(
          future: fetchAllData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  Helper.greeting(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: fontWeightNormal,
                                    color: textColorLight,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _dokter['data']['nm_dokter'],
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: textColorLight,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      child: cardStats(
                                        "Pasien Hari Ini",
                                        0.toString(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      child: cardStats(
                                        "Pasien Rawat Inap",
                                        "0",
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: cardStats(
                                        "Pasien Rawat Jalan",
                                        "0",
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DefaultTabController(
                      length: 2,
                      child: DraggableScrollableSheet(
                        initialChildSize: heightDragsheet,
                        minChildSize: heightDragsheet,
                        maxChildSize: 1,
                        builder: (context, scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(.5),
                                  blurRadius: 5,
                                  offset: const Offset(0, -3),
                                ),
                              ],
                              color: textColorLight,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                TabBar(
                                  isScrollable: true,
                                  labelColor: primaryColor,
                                  indicatorColor: primaryColor,
                                  unselectedLabelColor:
                                      textColor.withOpacity(0.2),
                                  padding: const EdgeInsets.all(10),
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: primaryColor.withOpacity(0.2),
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
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //     horizontal: 10,
                                    //   ),
                                    //   child: const Tab(text: 'Jadwal Operasi'),
                                    // ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      CreatePasienList(
                                        scrollController: scrollController,
                                        pasien: filterPasienRawatInap(_pasienNow['data']['data']),
                                      ),
                                      CreatePasienList(
                                        scrollController: scrollController,
                                        pasien: filterPasienRawatJalan(_pasienNow['data']['data'])
                                      ),
                                      // CreatePasienList(
                                      //   scrollController: scrollController,
                                      //   pasien: snapshot.data!,
                                      // ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            } else {
              return loadingku(textColorLight);
            }
          },
        ),
      ),
    );
  }
}
