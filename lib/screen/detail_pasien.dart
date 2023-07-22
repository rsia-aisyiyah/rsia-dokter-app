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

  const DetailPasien({
    super.key,
    required this.noRawat,
    required this.kategori,
  });

  @override
  State<DetailPasien> createState() => _DetailPasienState();
}

class _DetailPasienState extends State<DetailPasien> {
  fetchPasien() async {
    var response = await Api().postData({
      "no_rawat": widget.noRawat,
    }, '/dokter/pasien/pemeriksaan');

    var body = json.decode(response.body);
    return body;
  }

  @override
  Widget build(BuildContext context) {
    Color? bgColor =
        widget.kategori == 'umum' ? Colors.orange[100] : backgroundColor;
    Color? appBarColor =
        widget.kategori == 'umum' ? Colors.orange.shade400 : accentColor;

    return FutureBuilder(
      future: fetchPasien(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingku(primaryColor);
        } else {
          var data = json.decode(json.encode(snapshot.data));
          if (!data['success']) {
            return _pemeriksaanNull(context);
          } else {
            var pasien = data['data'];
            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: appBarColor,
                title: const Text('Detail Pasien'),
                leading: IconButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pasienDetails(pasien),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'History Pemeriksaan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: fontWeightSemiBold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          height: 1,
                          color: textColor,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                      pasien['pemeriksaan'] == null
                          ? _pemeriksaanNull(context)
                          : _buildPemeriksaanDetails(pasien),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Container _pemeriksaanNull(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.all(15),
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1.3,
          color: widget.kategori == 'umum' ? Colors.orange : accentColor,
        ),
      ),
      child: Text(
        'Pasien belum melakukan pemeriksaan',
        style: TextStyle(
          color: widget.kategori == 'umum' ? Colors.orange[700] : accentColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  _buildPemeriksaanDetails(pasien) {
    if (pasien['status_lanjut'].toString().toLowerCase() == 'ralan') {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom:20),
        child: TableHasilPemeriksaan(
          pasien: pasien,
        ),
      );
    } else {
      if (pasien['pemeriksaan'].isNotEmpty) {
        var pemeriksan = pasien['pemeriksaan'];
        return Column(
          children: List.generate(pemeriksan.length, (index) {
            int selectedTile = -1;
            final tglPerawatan = DateFormat(
              "EEEE, d MMMM yyyy",
              'id_ID',
            ).format(DateTime.parse(pemeriksan[index]['tgl_perawatan']));
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                clipBehavior: Clip.hardEdge,
                key: Key(index.toString()),
                textColor: accentColor,
                iconColor: accentColor,
                backgroundColor: Colors.white,
                initiallyExpanded: index == selectedTile,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tglPerawatan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(pemeriksan[index]['jam_rawat'])
                  ],
                ),
                onExpansionChanged: ((newState) {
                  if (newState) {
                    setState(() {
                      selectedTile = index;
                    });
                  } else {
                    setState(() {
                      selectedTile = -1;
                    });
                  }
                }),
                children: [
                  TablePemeriksaan(
                    pasien: pemeriksan[index],
                  ),
                ],
              ),
            );
          }),
        );
      } else {
        return _pemeriksaanNull(context);
      }
    }
  }

  Widget _pasienDetails(pasien) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pasien['pasien']['nm_pasien'],
            style: const TextStyle(
              fontSize: 30,
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
    );
  }
}
