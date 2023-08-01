import 'package:flutter/material.dart';
import 'package:rsiap_dokter/components/cards/card_stats.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/helper.dart';

class StatsHomeWidget extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final dokter, totalHariIni, pasienNow;
  const StatsHomeWidget({super.key, this.dokter, this.pasienNow, this.totalHariIni});

  // filter pasien rawat inap
  List filterPasienRawat(String status) {
    if (status.isNotEmpty) {
      List pasienFiltered = [];
      for (var i = 0; i < pasienNow.length; i++) {
        if (pasienNow[i]['status_lanjut'].toString().toLowerCase() ==
            status.toLowerCase()) {
          pasienFiltered.add(pasienNow[i]);
        }
      }
      return pasienFiltered;
    }

    return pasienNow;
  }

  double monthBetween(DateTime endDate) {
    var now = DateTime.now();
    var difference = endDate.difference(now).inDays;
    var month = difference / 30;
    return month;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    var STRExpired = monthBetween(DateTime.parse(
      dokter['data']['pegawai']['kualifikasi_staff']['tanggal_akhir_str'],
    ));

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
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: STRExpired <= STRExpMin
                  ? const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    )
                  : const EdgeInsets.all(0),
              width: double.infinity,
              decoration: STRExpired <= STRExpMin
                  ? BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(5),
                    )
                  : null,
              child: STRExpired <= STRExpMin
                  ? RichText(
                      text: TextSpan(
                        text: strExpiredIn,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                        children: [
                          TextSpan(
                            text: "${STRExpired.toStringAsFixed(1)} Bulan",
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: fontWeightSemiBold,
                            ),
                          ),
                          TextSpan(
                            text: ". $strRenewText",
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RichText(
                      text: TextSpan(
                        text: "SIP : ",
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                        children: [
                          TextSpan(
                            text: dokter['data']['pegawai']['kualifikasi_staff']
                                ['nomor_sip'],
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: fontWeightSemiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: STRExpired <= STRExpMin ? 10 : 15),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: cardStats(
                      todayText,
                      totalHariIni.toString(),
                      context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: cardStats(
                      rawatInapText,
                      filterPasienRawat("ranap").length.toString(),
                      context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: cardStats(
                      rawatJalanText,
                      filterPasienRawat("ralan").length.toString(),
                      context,
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
