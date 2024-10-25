import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/extensions/sensor.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';

class CardListPasienRadiologi extends StatelessWidget {
  final String penjab;
  final Map pasien;

  const CardListPasienRadiologi({
    super.key,
    required this.penjab,
    required this.pasien,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: 20,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Helper.penjabColor(penjab),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Helper.penjabOpacityColor(penjab),
                    blurRadius: 5,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (pasien['reg_periksa']['pasien']['nm_pasien'] as String).sensor(8) ?? '-',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: fontSemiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GenTable(data: {
                    ikNoRm: (pasien['reg_periksa']['no_rkm_medis'] as String).sensor(4),
                    ikNoRawat: (pasien['no_rawat'] as String).sensor(8),
                    'Permintaan': "${Helper.formatDate3(pasien['permintaan']['tgl_permintaan'])} | ${pasien['permintaan']['jam_permintaan']}",
                    "Pemeriksaan": pasien['permintaan']['tgl_sampel'] != "0000-00-00" ? "${Helper.formatDate3(pasien['permintaan']['tgl_sampel'])} | ${pasien['permintaan']['jam_sampel']}": '-',
                    "Info Klinis": pasien['permintaan']['informasi_tambahan'] ?? '-',
                    "Diagnosa Klinis": pasien['permintaan']['diagnosa_klinis'] ?? '-',
                    "Jenis Perawatan": pasien['jenis']['nm_perawatan']
                  }),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: pasien['hasil'] != null && pasien['hasil'].isNotEmpty ? Helper.penjabColor(penjab) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              color: pasien['hasil'] != null && pasien['hasil'].isNotEmpty ? textWhite : Colors.grey.shade500,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Hasil Radiologi",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: fontSemiBold,
                                color: pasien['hasil'] != null && pasien['hasil'].isNotEmpty ? textWhite : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Helper.penjabColor(penjab),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  penjab,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: fontSemiBold,
                    color: textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
