import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';

createCardPasien(pasien) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: penjab.toLowerCase().contains("bpjs")
                    ? accentColor
                    : warningColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: penjab.toLowerCase().contains("bpjs")
                      ? accentColor.withOpacity(.3)
                      : warningColor.withOpacity(.3),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$ikNoRkmMedis : ${pasien['no_rkm_medis']}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "$ikNoRawat : ${pasien['no_rawat']}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: penjab.toLowerCase().contains("bpjs")
                    ? accentColor
                    : warningColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                penjab,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
    ],
  );
}
