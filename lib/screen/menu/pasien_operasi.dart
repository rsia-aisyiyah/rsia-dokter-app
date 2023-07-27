import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/config.dart';
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
    var res = await Api().getData('/dokter/jadwal/operasi/2023/06');
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
          title: Text(
            "Pasien Operasi",
            style: const TextStyle(
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
              var dataJdwl = dataJadwal[i];
              return InkWell(
                onTap: () {
                  onListJadwalTap(context, dataJdwl);
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _getPenjab(
                                dataJdwl['reg_periksa']['penjab']['png_jawab'],
                              ).contains('BPJS')
                                  ? accentColor
                                  : warningColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getPenjab(
                                  dataJdwl['reg_periksa']['penjab']
                                      ['png_jawab'],
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
                                dataJdwl['reg_periksa']['pasien']['nm_pasien'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Flex(
                                direction: Axis.horizontal,
                                children: [
                                  Text(
                                    dataJdwl['no_rawat'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "( RM. ${dataJdwl['reg_periksa']['no_rkm_medis']} )",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: fontWeightSemiBold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _tableOperasi(dataJdwl)
                            ],
                          ),
                        ),
                        _labelPenjab(dataJdwl),
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

  Positioned _labelPenjab(dataJdwl) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: _getPenjab(
            dataJdwl['reg_periksa']['penjab']['png_jawab'],
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
            dataJdwl['reg_periksa']['penjab']['png_jawab'],
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

  Table _tableOperasi(dataJdwl) {
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
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  "Diagnosa",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  dataJdwl['rsia_diagnosa_operasi']['diagnosa'],
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
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  "Jenis Operasi",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  dataJdwl['paket_operasi']['nm_perawatan'],
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
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  "Jam",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  dataJdwl['jam_mulai'] + " - " + dataJdwl['jam_selesai'],
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

  Future<dynamic> onListJadwalTap(BuildContext context, dataJdwl) {
    return showModalBottomSheet(
      context: context,
      enableDrag: true,
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        dataJdwl['reg_periksa']['pasien']['nm_pasien'],
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        dataJdwl['no_rawat'],
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        dataJdwl['reg_periksa']['no_rkm_medis'],
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Diagnosa",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        dataJdwl['rsia_diagnosa_operasi']['diagnosa'],
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Jenis Operasi",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        dataJdwl['paket_operasi']['nm_perawatan'],
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Tanggal",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        dataJdwl['tanggal'],
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Jam",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        dataJdwl['jam_mulai'] + " - " + dataJdwl['jam_selesai'],
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
        );
      },
    );
  }
}
