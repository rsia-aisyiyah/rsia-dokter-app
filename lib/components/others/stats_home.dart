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
      key: key,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Helper.greeting(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: fontWeightNormal,
              color: textColorLight,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dokter['data']['nm_dokter'],
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: textColorLight,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            dokter['data']['no_ijn_praktek'],
            style: TextStyle(
              fontSize: 14,
              color: textColorLight,
            ),
          ),
          const SizedBox(height: 15),
          Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: cardStats(
                  "Pasien Hari Ini",
                  pasienNow['data']['total'].toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: cardStats(
                    "Pasien Rawat Inap",
                    filterPasienRawatInap(
                      pasienNow['data']['data'],
                    ).length.toString()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: cardStats(
                    "Pasien Rawat Jalan",
                    filterPasienRawatJalan(
                      pasienNow['data']['data'],
                    ).length.toString()),
              ),
            ],
          )
        ],
      ),
    );
  }
}
