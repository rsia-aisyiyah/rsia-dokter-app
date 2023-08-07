import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/utils/fonts.dart';

createCardJadwalOperasi(pasien) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: textWhite,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(.3),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pasien['no_rawat'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: fontBold,
              ),
            ),
            Text(
              pasien['tanggal'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: fontNormal,
              ),
            )
          ],
        ),
      ],
    ),
  );
}
