import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/detail/pasien.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';
import '../../utils/extensions/sensor.dart';

import 'package:rsiap_dokter/screen/detail/resume.dart';

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
              menuPasienCards(context, pasien);
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
                    (pasien['pasien']['nm_pasien'] as String).sensor(8) ?? "-",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: fontSemiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GenTable(data: {
                    ikNoRm: (pasien['no_rkm_medis'] as String).sensor(4),
                    ikNoRawat: (pasien['no_rawat'] as String).sensor(8),
                    if (pasien['kamar_inap'] == null) ...{
                      ikTglDaftar: Helper.formatDate2(pasien['tgl_registrasi'])
                    } else ...{
                      ikTglMasuk: "${Helper.formatDate2(pasien['kamar_inap']['tgl_masuk'])} ( ${pasien['kamar_inap']['lama']} Hari )",
                    },

                    if (pasien['kamar_inap'] != null) ...{
                      "Diagnosa Awal": pasien['kamar_inap']['diagnosa_awal'],
                    },

                    if (pasien['kamar_inap'] == null) ...{
                      poliklinikText: pasien['poliklinik']['nm_poli']
                    } else ...{
                      kamarInapText: pasien['kamar_inap']['kamar']['bangsal']['nm_bangsal'],
                    },

                    if (pasien['kamar_inap'] != null) ...{
                      "Status Pulang": pasien['kamar_inap']['stts_pulang'],
                    }
                  }),
                  const SizedBox(height: 10),
                  badgeResume(pasien, penjab),
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
                  if (rg['reg_periksa']['penjab'] == null) {
                    rg['reg_periksa']['penjab'] = pasien['penjab'];
                  }
                  menuPasienCards(context, rg['reg_periksa']);
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
                      const SizedBox(height: 10),
                      badgeResume(rg['reg_periksa'], penjab),
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

Wrap badgeResume(pasien, String penjab) {
  return Wrap(
    spacing: 7,
    runSpacing: 10,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: pasien['resume_pasien_ranap'] != null ? Helper.penjabColor(penjab) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              color: pasien['resume_pasien_ranap'] != null ? textWhite : Colors.grey.shade500,
              size: 18,
            ),
            const SizedBox(width: 5),
            Text(
              "Resume Medis",
              style: TextStyle(
                fontSize: 12,
                fontWeight: fontSemiBold,
                color: pasien['resume_pasien_ranap'] != null ? textWhite : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Future<dynamic> menuPasienCards(BuildContext context, pasien) {
  return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Menu Pasien",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: fontSemiBold,
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        Icons.close,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GenTable(data: {
                ikName: (pasien['pasien']['nm_pasien'] as String).sensor(8),
                ikNoRm: (pasien['no_rkm_medis'] as String).sensor(4),
                ikNoRawat: (pasien['no_rawat'] as String).sensor(8),
              }),
              const SizedBox(height: 20),
              Text(
                "Menu",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: fontSemiBold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Detail Pemeriksaan",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: fontSemiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pasien['resume_pasien_ranap'] != null ? InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResumePasienRanap(
                            noRawat: pasien['no_rawat'],
                            kategori:
                                Helper.getPenjab(pasien['penjab']['png_jawab']),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Resume Medis",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: fontSemiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ) : Container(),
                ],
              ),
            ],
          ),
        );
      });
}
