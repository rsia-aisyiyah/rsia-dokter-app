import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';

class TableHasilPemeriksaan extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final pasien;
  const TableHasilPemeriksaan({super.key, required this.pasien});

  @override
  Widget build(BuildContext context) {
    TextAlign alignValue = TextAlign.end;
    final tglPerawatan = DateFormat("EEEE, d MMMM yyyy", 'id_ID').format(
      DateTime.parse(pasien['pemeriksaan']['tgl_perawatan']),
    );

    List tableContent = [
      {"label": "Tanggal Pemerksaan", "value": tglPerawatan},
      {"label": "Jam Rawat", "value": pasien['pemeriksaan']['jam_rawat']},
      {"label": "Alergi", "value": pasien['pemeriksaan']['alergi']},
      {"label": "Suhu (C)", "value": pasien['pemeriksaan']['suhu_tubuh']},
      {"label": "Tensi (mmHg)", "value": pasien['pemeriksaan']['tensi']},
      {"label": "Nadi (/ menit)", "value": pasien['pemeriksaan']['nadi']},
      {"label": "RR (/ menit)", "value": pasien['pemeriksaan']['respirasi']},
      {"label": "GCS (E,V,M)", "value": pasien['pemeriksaan']['gcs']},
      {"label": "SPO2", "value": pasien['pemeriksaan']['spo2']},
      {"label": "Berat Badan (Kg)", "value": pasien['pemeriksaan']['berat']},
      {"label": "Tinggi Badan (Cm)", "value": pasien['pemeriksaan']['tinggi']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: bgWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Helper.penjabColor(pasien['penjab']['png_jawab']),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 3),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                checkUpResult,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: fontSemiBold,
                ),
              ),
              const SizedBox(height: 10),
              Table(
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
              color: Helper.penjabColor(pasien['penjab']['png_jawab']),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 3),
              )
            ],
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
                pasien['pemeriksaan']['kesadaran'],
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
              color: Helper.penjabColor(pasien['penjab']['png_jawab']),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 3),
              )
            ],
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
                pasien['pemeriksaan']['keluhan'],
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
              color: Helper.penjabColor(pasien['penjab']['png_jawab']),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 3),
              )
            ],
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
                pasien['pemeriksaan']['pemeriksaan'],
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
              color: Helper.penjabColor(pasien['penjab']['png_jawab']),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 3),
              )
            ],
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
                pasien['pemeriksaan']['penilaian'],
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
              color: Helper.penjabColor(pasien['penjab']['png_jawab']),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 3),
              )
            ],
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
                pasien['pemeriksaan']['rtl'],
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
              color: Helper.penjabColor(pasien['penjab']['png_jawab']),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 3),
              )
            ],
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
                pasien['pemeriksaan']['instruksi'],
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
              color: Helper.penjabColor(pasien['penjab']['png_jawab']),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 3),
              )
            ],
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
                pasien['pemeriksaan']['evaluasi'],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
