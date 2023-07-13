import 'package:flutter/material.dart';
import 'package:rsiap_dokter/components/cards/card_stats.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/helper.dart';

class StatsHomeWidget extends StatelessWidget {
  final dokter, pasienNow;
  const StatsHomeWidget({super.key, this.dokter, this.pasienNow});

  // filter pasien rawat inap
  List filterPasienRawatInap(List pasien) {
    List pasienRawatInap = [];
    for (var i = 0; i < pasien.length; i++) {
      if (pasien[i]['status_lanjut'] == 'Ranap') {
        pasienRawatInap.add(pasien[i]);
      }
    }
    return pasienRawatInap;
  }

  List filterPasienRawatJalan(List pasien) {
    List pasienRawatJalan = [];
    for (var i = 0; i < pasien.length; i++) {
      if (pasien[i]['status_lanjut'] == 'Ralan') {
        pasienRawatJalan.add(pasien[i]);
      }
    }
    return pasienRawatJalan;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(15),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Helper.greeting(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: fontWeightNormal,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              dokter['data']['nm_dokter'],
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Akhir STR " + dokter['data']['pegawai']['kualifikasi_staff']['tanggal_akhir_str'],
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
            const SizedBox(height: 15),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: cardStats(
                      "Hari Ini",
                      pasienNow['data']['total'].toString(),
                      context
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: cardStats(
                      "Rawat Inap",
                      filterPasienRawatInap(
                        pasienNow['data']['data'],
                      ).length.toString(),
                      context
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: cardStats(
                      "Rawat Jalan",
                      filterPasienRawatJalan(
                        pasienNow['data']['data'],
                      ).length.toString(),
                      context
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
