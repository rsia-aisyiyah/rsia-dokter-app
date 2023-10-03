import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/detail/pasien.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';

createCardPasien(pasien, context) {
  var rg = pasien['ranap_gabung'] ?? [];

  var penjab = "";
  if (pasien['penjab']['png_jawab'].toString().contains('/')) {
    penjab = pasien['penjab']['png_jawab'].toString().split('/').last;
    penjab = "BPJS$penjab";
  } else {
    penjab = pasien['penjab']['png_jawab'];
  }

  return Column(
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPasien(
                    noRawat: pasien['no_rawat'],
                    kategori: Helper.getPenjab(pasien['penjab']['png_jawab']),
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.only(
                top: 25,
                left: 15,
                right: 15,
                bottom: rg.isEmpty ? 15 : 25,
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
                    pasien['pasien']['nm_pasien'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: fontSemiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GenTable(data: {
                    ikNoRm: pasien['no_rkm_medis'],
                    ikNoRawat: pasien['no_rawat'],
                    if (pasien['kamar_inap'] == null)
                      ikTglDaftar: Helper.formatDate2(pasien['tgl_registrasi'])
                    else
                      ikTglMasuk: "${Helper.formatDate2(pasien['kamar_inap']['tgl_masuk'])}   ( ${pasien['kamar_inap']['lama']} Hari )",
                    
                    if (pasien['kamar_inap'] != null)
                      "Diagnosa Awal": pasien['kamar_inap']['diagnosa_awal'],
                    
                    if (pasien['kamar_inap'] == null)
                      poliklinikText: pasien['poliklinik']['nm_poli']
                    else
                      kamarInapText: pasien['kamar_inap']['kamar']['bangsal']['nm_bangsal'],
                    
                    if (pasien['kamar_inap'] != null)
                      "Status Pulang": pasien['kamar_inap']['stts_pulang'],
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Helper.penjabColor(penjab),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
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
      rg.isEmpty
          ? Container()
          : Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPasien(
                          noRawat: rg['reg_periksa']['no_rawat'],
                          kategori: Helper.getPenjab(pasien['penjab']['png_jawab']),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 25,
                      left: 15,
                      right: 15,
                      bottom: 15,
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
                          rg['reg_periksa']['pasien']['nm_pasien'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: fontSemiBold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GenTable(data: {
                          ikNoRm: rg['reg_periksa']['no_rkm_medis'],
                          ikNoRawat: rg['reg_periksa']['no_rawat'],
                        }),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  top: -14,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        border: Border.all(
                          color: Colors.orange.shade500,
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      child: Text(
                        "RAWAT GABUNG",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: fontSemiBold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
      const SizedBox(height: 15),
    ],
  );
}
