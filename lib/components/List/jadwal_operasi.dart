import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/box_message.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';

class ListJadwalOperasi extends StatefulWidget {
  const ListJadwalOperasi({super.key});

  @override
  State<ListJadwalOperasi> createState() => _ListJadwalOperasiState();
}

class _ListJadwalOperasiState extends State<ListJadwalOperasi> {
  String nextPageUrl = '';
  String prevPageUrl = '';
  String currentPage = '';
  String lastPage = '';

  List dataJadwal = [];

  bool isLoading = true;
  bool btnLoading = false;

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

// Load More
  Future<void> loadMore() async {
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
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 3,
        child: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dataJadwal.isEmpty ? 1 : dataJadwal.length,
            itemBuilder: (context, i) {
              if (dataJadwal.isEmpty) {
                return const BoxMessage(
                  title: "Tidak ada jadwal operasi",
                  body: "Tidak ada jadwal operasi yang tersedia",
                );
              } else {
                var dataJdwl = dataJadwal[i];
                var pjab = Helper.getPenjab(
                  dataJdwl['reg_periksa']['penjab']['png_jawab'],
                );

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
                              color: bgWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Helper.penjabColor(pjab),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Helper.penjabOpacityColor(pjab),
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
                                  dataJdwl['reg_periksa']['pasien']
                                      ['nm_pasien'],
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
                                      "( $ikRm. ${dataJdwl['reg_periksa']['no_rkm_medis']} )",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: fontSemiBold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                GenTable(data: {
                                  labelDates: Helper.formatDate(dataJdwl['tanggal']),
                                  labelTime: dataJdwl['jam_mulai'] +
                                      " - " +
                                      dataJdwl['jam_selesai'],
                                  ikDiagnosis: dataJdwl['rsia_diagnosa_operasi']
                                      ['diagnosa'],
                                  ikJenisOperasi: dataJdwl['paket_operasi']
                                      ['nm_perawatan'],
                                }),
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
              }
            },
          ),
          _loadmoreButton(),
        ],
      );
    }
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
          child: GenTable(data: {
            ikPasien: dataJdwl['reg_periksa']['pasien']['nm_pasien'],
            ikNoRawat: dataJdwl['no_rawat'],
            ikNoRm: dataJdwl['reg_periksa']['no_rkm_medis'],
            ikDiagnosis: dataJdwl['rsia_diagnosa_operasi']['diagnosa'],
            ikJenisOperasi: dataJdwl['paket_operasi']['nm_perawatan'],
            labelDates: Helper.formatDate(dataJdwl['tanggal']),
            labelTime: dataJdwl['jam_mulai'] + " - " + dataJdwl['jam_selesai'],
          }),
        );
      },
    );
  }

  Positioned _labelPenjab(dataJdwl) {
    var pjab = Helper.getPenjab(
      dataJdwl['reg_periksa']['penjab']['png_jawab'],
    );
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Helper.penjabColor(pjab),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Text(
          Helper.getRealPenjab(dataJdwl['reg_periksa']['penjab']['png_jawab']),
          style: TextStyle(
            fontSize: 11,
            fontWeight: fontSemiBold,
            color: textWhite,
          ),
        ),
      ),
    );
  }

  Widget _loadmoreButton() {
    if (nextPageUrl.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 20,
          top: 5,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: textColor, width: 1.5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: btnLoading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            : IconButton(
                onPressed: () async {
                  setState(() {
                    btnLoading = true;
                  });

                  await loadMore();
                  setState(() {
                    btnLoading = false;
                  });
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: textColor,
                ),
              ),
      );
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }
}
