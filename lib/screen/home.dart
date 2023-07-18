import 'dart:convert';

import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/List/pasien.dart';
import 'package:rsiap_dokter/components/List/jadwal_operasi.dart';
import 'package:rsiap_dokter/components/cards/card_list_pasien.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/components/others/stats_home.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/screen/detail_pasien.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  // Data
  var _jadwalOperasi = {};
  var _pasienNow = {};
  var _dokter = {};

  // Pagination
  var currentPage = 1;
  var lastPage = 1;
  var nextPageUrl = '';
  var prevPageUrl = '';

  // Data
  List dataPasien = [];

  @override
  void initState() {
    super.initState();
    fetchAllData().then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;

          // Pagination
          currentPage = _pasienNow['data']['current_page'];
          lastPage = _pasienNow['data']['last_page'];
          nextPageUrl = _pasienNow['data']['next_page_url'];
          prevPageUrl = _pasienNow['data']['prev_page_url'];
        });
      }
    });
  }

  // ---------------------- Fetch Data

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
        dataPasien = body['data']['data'];
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

  // ---------------------- End Fetch Data

  // ---------------------- Load More Data

  Future<void> loadMoreData() async {
    if (nextPageUrl.isNotEmpty) {
      var res = await Api().getDataUrl(nextPageUrl);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        setState(() {
          _pasienNow = body;
          dataPasien.addAll(body['data']['data']);

          // pagination
          currentPage = _pasienNow['data']['current_page'];
          lastPage = _pasienNow['data']['last_page'];
          nextPageUrl = _pasienNow['data']['next_page_url'];
          prevPageUrl = _pasienNow['data']['prev_page_url'];
        });
      }
    }
  }

  // ---------------------- End Load More Data

  // ---------------------- Filter Pasien

  List filterPasienRawat(String status) {
    if (status.isNotEmpty) {
      List pasienFiltered = [];
      for (var i = 0; i < dataPasien.length; i++) {
        if (dataPasien[i]['status_lanjut'].toString().toLowerCase() ==
            status.toLowerCase()) {
          pasienFiltered.add(dataPasien[i]);
        }
      }
      return pasienFiltered;
    }

    return dataPasien;
  }

  // ---------------------- End Filter Pasien

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingku(primaryColor);
    } else {
      return DefaultTabController(
        length: 3,
        child: LazyLoadScrollView(
          onEndOfPage: () => loadMoreData(),
          child: DraggableHome(
            title: const Text("Draggable Home"),
            headerWidget: StatsHomeWidget(
              dokter: _dokter,
              pasienNow: dataPasien,
              totalHariIni: _pasienNow['data']['total'],
            ),
            body: List.of([
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataPasien.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPasien(
                            noRawat: dataPasien[index]['no_rawat'],
                            kategori: dataPasien[index]['penjab']['png_jawab']
                                    .toString()
                                    .toLowerCase()
                                    .contains("umum")
                                ? "umum"
                                : "bpjs",
                          ),
                        ),
                      );
                    },
                    child: createCardPasien(dataPasien[index]),
                  );
                },
              )
            ], growable: true),
            // body: Row(
            //   children: [
            //     const Spacer(),
            //     Container(
            //       height: 3,
            //       width: 60,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(15.0),
            //         color: Colors.grey,
            //       ),
            //     ),
            //     const Spacer(),
            //   ],
            // ),
            // IntrinsicHeight(
            //   child: TabBar(
            //     isScrollable: true,
            //     labelColor: accentColor,
            //     indicatorColor: primaryColor,
            //     unselectedLabelColor: textColor.withOpacity(0.2),
            //     padding: const EdgeInsets.all(10),
            //     indicator: BoxDecoration(
            //       borderRadius: BorderRadius.circular(100),
            //       color: primaryColor.withOpacity(0.2),
            //     ),
            //     unselectedLabelStyle: TextStyle(
            //       fontSize: 14,
            //       fontWeight: fontWeightNormal,
            //     ),
            //     labelStyle: TextStyle(
            //       fontSize: 14,
            //       fontWeight: fontWeightBold,
            //     ),
            //     tabs: [
            //       Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 10,
            //         ),
            //         child: const Tab(text: 'Rawat Inap'),
            //       ),
            //       Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 10,
            //         ),
            //         child: const Tab(text: 'Rawat Jalan'),
            //       ),
            //       Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 10,
            //         ),
            //         child: const Tab(text: 'Jadwal Operasi'),
            //       ),
            //     ],
            //   ),
            // ),
            // Container(
            //   child: TabBarView(
            //     children: [
            //       CreatePasienList(
            //         pasien: filterPasienRawat("Ranap"),
            //         loadMore: loadMoreData,
            //         title: "Rawat Inap",
            //       ),
            //       CreatePasienList(
            //         pasien: filterPasienRawat("Ralan"),
            //         loadMore: loadMoreData,
            //         title: 'Rawat Jalan',
            //       ),
            //       CreateJadwalOperasiList(
            //         pasien: _jadwalOperasi['data']['data'],
            //       ),
            //     ],
            //   ),
            // ),
            fullyStretchable: false,
            backgroundColor: Colors.white,
            appBarColor: primaryColor,
          ),
        ),
      );
    }
  }
}
