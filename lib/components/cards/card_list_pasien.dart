import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

createCardPasien(pasien) {
  var penjab = "";
  if (pasien['penjab']['png_jawab'].toString().contains('/')) {
    penjab = pasien['penjab']['png_jawab'].toString().split('/').last;
  } else {
    penjab = pasien['penjab']['png_jawab'];
  }

  return Stack(
    children: [
      Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: 15,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: penjab.toLowerCase().contains("umum")
                ? warningColor
                : accentColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(.3),
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
              "RM : ${pasien['no_rkm_medis']}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "No. Rawat : ${pasien['no_rawat']}",
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
        top: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color:
                pasien['penjab']['png_jawab'].toString().toLowerCase() == "umum"
                    ? warningColor
                    : accentColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          child: Text(
            penjab.toLowerCase().contains("umum") ? penjab : "BPJS$penjab",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}
