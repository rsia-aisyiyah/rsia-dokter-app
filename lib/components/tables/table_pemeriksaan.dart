import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';

class TablePemeriksaan extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final pasien;
  final String? penjab;
  final String? statusLanjut;
  const TablePemeriksaan(
      {super.key,
      required this.pasien,
      required this.penjab,
      required this.statusLanjut});

  @override
  Widget build(BuildContext context) {
    TextAlign alignValue = TextAlign.end;
    final tglPerawatan = DateFormat("EEEE, d MMMM yyyy", 'id_ID').format(
      DateTime.parse(pasien['tgl_perawatan']),
    );

    List tableContent = [
      {"label": "Tanggal", "value": tglPerawatan},
      {"label": "Jam Rawat", "value": pasien['jam_rawat']},
      {"label": "Alergi", "value": pasien['alergi']},
      {"label": "Suhu (C)", "value": pasien['suhu_tubuh']},
      {"label": "Tensi (mmHg)", "value": pasien['tensi']},
      {"label": "Nadi (/ menit)", "value": pasien['nadi']},
      {"label": "RR (/ menit)", "value": pasien['respirasi']},
      {"label": "GCS (E,V,M)", "value": pasien['gcs']},
      {"label": "SPO2", "value": pasien['spo2']},
      {"label": "Berat Badan (Kg)", "value": pasien['berat']},
      {"label": "Tinggi Badan (Cm)", "value": pasien['tinggi']},
    ];

    return Container(
      color: statusLanjut == 'ralan' ? Colors.transparent : bgWhite,
      padding: EdgeInsets.symmetric(
        horizontal: statusLanjut == 'ralan' ? 0 : 15,
        vertical: statusLanjut == 'ralan' ? 10 : 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor(penjab!),
                width: 1.2,
              ),
            ),
            child: Table(
              children: tableContent.map((item) {
                return TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: fontSemiBold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          item['value'],
                          textAlign: alignValue,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor(penjab!),
                width: 1.2,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Helper.penjabOpacityColor(penjab!),
              //     blurRadius: 2,
              //     offset: const Offset(3, 3),
              //   )
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ikAwareness,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontSemiBold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pasien['kesadaran'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor(penjab!),
                width: 1.2,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Helper.penjabOpacityColor(penjab!),
              //     blurRadius: 2,
              //     offset: const Offset(3, 3),
              //   )
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ikSubjective,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontSemiBold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pasien['keluhan'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor(penjab!),
                width: 1.2,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Helper.penjabOpacityColor(penjab!),
              //     blurRadius: 2,
              //     offset: const Offset(3, 3),
              //   )
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ikObjective,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontSemiBold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pasien['pemeriksaan'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor(penjab!),
                width: 1.2,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Helper.penjabOpacityColor(penjab!),
              //     blurRadius: 2,
              //     offset: const Offset(3, 3),
              //   )
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ikAssesment,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontSemiBold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pasien['penilaian'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor(penjab!),
                width: 1.2,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Helper.penjabOpacityColor(penjab!),
              //     blurRadius: 2,
              //     offset: const Offset(3, 3),
              //   )
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ikPlanning,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontSemiBold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pasien['rtl'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor(penjab!),
                width: 1.2,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Helper.penjabOpacityColor(penjab!),
              //     blurRadius: 2,
              //     offset: const Offset(3, 3),
              //   )
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ikInstruction,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontSemiBold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pasien['instruksi'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor(penjab!),
                width: 1.2,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Helper.penjabOpacityColor(penjab!),
              //     blurRadius: 2,
              //     offset: const Offset(3, 3),
              //   )
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ikEvaluation,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontSemiBold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pasien['evaluasi'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
