import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/screen/detail/operasi.dart';
import 'package:rsiap_dokter/utils/msg.dart';

class PasienOperasi extends StatefulWidget {
  const PasienOperasi({super.key});

  @override
  State<PasienOperasi> createState() => _PasienOperasiState();
}

class _PasienOperasiState extends State<PasienOperasi> {
  String nextPageUrl = '';
  String prevPageUrl = '';
  String currentPage = '';
  String lastPage = '';

  List dataJadwal = [];

  bool isLoading = true;

  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  Future fetchPasien() async {
    var res = await Api().getData('/dokter/operasi');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    }
  }

  void _setData(value) {
    if (value['data']['total'] != 0) {
      setState(() {
        dataJadwal = value['data']['data'] ?? [];

        nextPageUrl = value['data']['next_page_url'] ?? '';
        prevPageUrl = value['data']['prev_page_url'] ?? '';
        currentPage = value['data']['current_page'].toString();
        lastPage = value['data']['last_page'].toString();

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;

        dataJadwal = value['data']['data'] ?? [];
      });
    }
  }

  Future<void> _loadMore() async {
    if (nextPageUrl.isNotEmpty) {
      var res = await Api().getDataUrl(nextPageUrl);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        setState(() {
          dataJadwal.addAll(body['data']['data']);

          nextPageUrl = body['data']['next_page_url'] ?? '';
          prevPageUrl = body['data']['prev_page_url'] ?? '';
          currentPage = body['data']['current_page'].toString();
          lastPage = body['data']['last_page'].toString();
        });
      }
    }

    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    await fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }

      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingku(primaryColor);
    } else {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            "Pasien Operasi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: accentColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Msg.warning(
                  context,
                  "Fitur ini belum tersedia",
                );
              },
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          onLoading: _loadMore,
          header: WaterDropMaterialHeader(
            color: Colors.white,
            backgroundColor: accentColor,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            itemCount: dataJadwal.length,
            itemBuilder: (context, i) {
              var dataOperasi = dataJadwal[i];
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OperasiDetail(
                          noRawat: dataOperasi['no_rawat'],
                          pasien: dataOperasi['pasien'],
                          penjab: _getPenjab(
                            dataOperasi['penjab']['png_jawab'],
                          ),
                          rm: dataOperasi['no_rkm_medis'],
                          statusLanjut: dataOperasi['status_lanjut'],
                        ),
                      ));
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _getPenjab(
                                dataOperasi['penjab']['png_jawab'],
                              ).contains('BPJS')
                                  ? accentColor
                                  : warningColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getPenjab(
                                  dataOperasi['penjab']['png_jawab'],
                                ).contains('BPJS')
                                    ? accentColor.withOpacity(.2)
                                    : warningColor.withOpacity(.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(2, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dataOperasi['pasien']['nm_pasien'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _tableOperasi(dataOperasi)
                            ],
                          ),
                        ),
                        _labelPenjab(dataOperasi),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  }

  String _getPenjab(penjab) {
    var plow = penjab.toString().toLowerCase();

    if (plow.contains('/')) {
      var p = "BPJS${plow.split('/').last.toUpperCase()}";
      return p;
    } else {
      var p = plow.toUpperCase();
      return p;
    }
  }

  Positioned _labelPenjab(dataOperasi) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: _getPenjab(
            dataOperasi['penjab']['png_jawab'],
          ).contains('BPJS')
              ? accentColor
              : warningColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Text(
          _getPenjab(
            dataOperasi['penjab']['png_jawab'],
          ),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Table _tableOperasi(dataOperasi) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      textBaseline: TextBaseline.alphabetic,
      children: [
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  "No. Rawat",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  dataOperasi['no_rawat'],
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  "RM",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  dataOperasi['no_rkm_medis'],
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<dynamic> onListJadwalTap(BuildContext context, dataOperasi) {
    // TODO : Height Modal Bottom Sheet sesuaikan dengan isi dari kontennya
    return showModalBottomSheet(
      context: context,
      enableDrag: false,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(
            right: 20,
            left: 20,
            bottom: 20,
          ),
          child: SingleChildScrollView(
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              textBaseline: TextBaseline.alphabetic,
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Pasien",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['pasien']['nm_pasien'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "No. Rawat",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['no_rawat'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "RM",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['no_rkm_medis'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Kategori Pasien",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['penjab']['png_jawab'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Perawatan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['operasi']['paket_operasi']
                              ['nm_perawatan'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Mulai",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['operasi']['laporan_operasi']['tanggal'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Selesai",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['operasi']['laporan_operasi']
                              ['selesaioperasi'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Diagnosa Sebelum Operasi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['operasi']['laporan_operasi']
                              ['diagnosa_preop'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Diagnosa Setelah Operasi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['operasi']['laporan_operasi']
                              ['diagnosa_postop'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Permintaan PA",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['operasi']['laporan_operasi']
                              ['permintaan_pa'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          "Laporan Operasi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          dataOperasi['operasi']['laporan_operasi']
                              ['laporan_operasi'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
