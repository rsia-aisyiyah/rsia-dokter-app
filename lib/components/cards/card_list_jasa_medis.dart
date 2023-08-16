import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';

createCardJasaMedis(jasamedis) {
  var seticon = "true";
  // var penjab = "";
  // if (pasien['penjab']['png_jawab'].toString().contains('/')) {
  //   penjab = pasien['penjab']['png_jawab'].toString().split('/').last;
  //   penjab = "BPJS$penjab";
  // } else {
  //   penjab = pasien['penjab']['png_jawab'];
  // }

  return Column(
    children: [
      Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: 25,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor("bpjs"),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Helper.penjabOpacityColor("bpjs"),
                  blurRadius: 5,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Helper.numToMonth(int.parse(jasamedis['bulan'])) +
                          " " +
                          jasamedis['tahun'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: fontSemiBold,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(seticon == true
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GenTable(
                  data: {
                    nominalText: Helper.numberFormat(jasamedis['jm_dokter']),
                    tambahanText:
                        '(+) ' + Helper.numberFormat(jasamedis['tambahan']),
                    potonganText:
                        '(-) ' + Helper.numberFormat(jasamedis['potongan']),
                    jasaMedisText:
                        Helper.numberFormat(jasamedis['jm_diterima']),
                    // if (pasien['kamar_inap'] == null)
                    //   ikTglDaftar: Helper.formatDate(pasien['tgl_registrasi'])
                    // else
                    //   ikTglDaftar:
                    //       "${Helper.formatDate(pasien['tgl_registrasi'])}   ( ${pasien['kamar_inap']['lama']} Hari )",
                    // if (pasien['kamar_inap'] != null)
                    //   "Diagnosa Awal": pasien['kamar_inap']['diagnosa_awal'],
                    // if (pasien['kamar_inap'] == null)
                    //   poliklinikText: pasien['poliklinik']['nm_poli']
                    // else
                    //   kamarInalText: pasien['kamar_inap']['kamar']['bangsal']
                    //       ['nm_bangsal'],
                    // if (pasien['kamar_inap'] != null)
                    //   "Status Pulang": pasien['kamar_inap']['stts_pulang'],
                  },
                  style: "right",
                ),
              ],
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 7,
          //       vertical: 5,
          //     ),
          //     decoration: BoxDecoration(
          //       color: Helper.penjabColor("bpjs"),
          //       borderRadius: const BorderRadius.only(
          //         topLeft: Radius.circular(10),
          //         bottomRight: Radius.circular(10),
          //       ),
          //     ),
          //     child: Text(
          //       penjab,
          //       style: TextStyle(
          //         fontSize: 11,
          //         fontWeight: fontSemiBold,
          //         color: textWhite,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      const SizedBox(height: 15),
    ],
  );
}
