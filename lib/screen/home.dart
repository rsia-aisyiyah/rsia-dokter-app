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
  var _pasienNow;
  var _ranapNow;
  var _ralanNow;
  var _dokter;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchAllData() async {
    // TODO : GET Pasien now, ranap dan ralan map di client, jadi tanpa melakukan request ke server lagi
    List<Future> futures = [
      _getDokter(),
      _getPasienNow(),
      _getRanapNow(),
      _getRalanNow(),
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
    var res = await Api().getData('/dokter/pasien/now');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      setState(() {
        _pasienNow = body;
      });
    }
  }

  Future<void> _getRanapNow() async {
    var res = await Api().getData('/dokter/pasien/ranap/now');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      setState(() {
        _ranapNow = body;
      });
    }
  }

  Future<void> _getRalanNow() async {
    var res = await Api().getData('/dokter/pasien/ralan/now');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      setState(() {
        _ralanNow = body;
      });
    }
  }

  final Future<List> _testList = Future<List>.delayed(
    const Duration(seconds: 2),
    () => List.generate(20, (i) => i + 1),
  );

  @override
  Widget build(BuildContext context) {
    var heightDragsheet = MediaQuery.of(context).size.height * 0.6 / MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: FutureBuilder(
          future: _testList,
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
                                  "Nama Dokter diambil dari API / Database",
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
                      length: 3,
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
                                    indicatorColor: primaryColor,
                                    labelColor: primaryColor,
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
                                    // tabs is mapping of mainTabs and get label
                                    tabs: const [
                                      Tab(text: "Semua"),
                                      Tab(text: "Rawat Inap"),
                                      Tab(text: "Rawat Jalan"),
                                    ]),
                                Expanded(
                                  child: TabBarView(children: [
                                    createListPasien(
                                        snapshot.data!, "", scrollController),
                                    createListPasien(snapshot.data!, "ranap",
                                        scrollController),
                                    createListPasien(snapshot.data!, "ralan",
                                        scrollController),
                                  ]),
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
