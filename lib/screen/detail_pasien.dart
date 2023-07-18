import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/components/tables/table_hasil_pemeriksaan.dart';
import 'package:rsiap_dokter/components/tables/table_pemeriksaan.dart';

import '../config/config.dart';

class DetailPasien extends StatefulWidget {
  final String noRawat;
  final String kategori;
  const DetailPasien(
      {super.key, required this.noRawat, required this.kategori});

  @override
  State<DetailPasien> createState() => _DetailPasienState();
}

class _DetailPasienState extends State<DetailPasien> {
  var pasien = {};

  fetchPasien() async {
    var response = await Api().postData({
      "no_rawat": widget.noRawat,
    }, '/dokter/pasien/pemeriksaan');

    var body = json.decode(response.body);
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.kategori == 'umum' ? Colors.orange.shade100 : backgroundColor,
      appBar: AppBar(
        backgroundColor: widget.kategori == 'umum' ? warningColor : accentColor,
        title: const Text('Detail Pasien'),
        // icon back
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: fetchPasien(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = json.decode(json.encode(snapshot.data));
              if (data['success']) {
                var pasien = data['data'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pasien['pasien']['nm_pasien'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              text: "RM : ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              children: [
                                TextSpan(
                                  text: pasien['no_rkm_medis'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          RichText(
                            text: TextSpan(
                              text: "No. Rawat : ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              children: [
                                TextSpan(
                                  text: pasien['no_rawat'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            pasien['poliklinik']['nm_poli'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pasien['pemeriksaan'] == null
                        ? _pemeriksaanNull()
                        : _buildPemeriksaanWidget(pasien)
                  ],
                );
              } else {
                return Center(
                  child: Text(
                    pasien['message'],
                  ),
                );
              }
            } else {
              return loadingku(primaryColor);
            }
          },
        ),
      ),
    );
  }

  _buildPemeriksaanWidget(pasien) {
    if (pasien['status_lanjut'].toString().toLowerCase() == 'ralan') {
      return Expanded(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            child: TableHasilPemeriksaan(pasien: pasien),
          ),
        ),
      );
    } else {
      if (pasien['pemeriksaan'].isNotEmpty) {
        return Expanded(
          child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ListView.builder(
                itemCount: pasien['pemeriksaan'].length,
                itemBuilder: (context, index) {
                  var pemeriksaan = pasien['pemeriksaan'][index];
                  final tglPerawatan =
                      DateFormat("EEEE, d MMMM yyyy", 'id_ID').format(
                    DateTime.parse(pemeriksaan['tgl_perawatan']),
                  );
                  return ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tglPerawatan, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(pemeriksaan['jam_rawat'])
                      ],
                    ),
                    textColor: accentColor,
                    iconColor: accentColor,
                    children: [
                      TablePemeriksaan(
                        pasien: pemeriksaan,
                      ),
                    ],
                  );
                },
              )),
        );
      } else {
        return _pemeriksaanNull();
      }
    }
  }

  _pemeriksaanNull() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: warningColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: warningColor.withOpacity(.5),
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        "Data Pemeriksaan Masih Kosong",
        style: TextStyle(
          color: warningColor,
          fontSize: 18,
          fontWeight: fontWeightSemiBold,
        ),
      ),
    );
  }
}
