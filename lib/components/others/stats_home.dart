import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rsiap_dokter/components/cards/card_stats.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';

class StatsHomeWidget extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final dokter, metrics;
  final Function onTap;
  const StatsHomeWidget({
    super.key,
    this.dokter,
    this.metrics,
    required this.onTap,
  });

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
      color: bgColor,
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flex(
                direction: Axis.horizontal,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: textWhite,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        imageUrl: photoUrl +
                            dokter['data']['pegawai']['photo'].toString(),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Helper.greeting(),
                          style: TextStyle(
                            fontSize: Helper.getFontSize(context, mobileBody),
                            fontWeight: fontNormal,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          dokter['data']['nm_dokter'],
                          style: TextStyle(
                            fontSize: Helper.getFontSize(
                                context,
                                STRExpired <= STRExpMin
                                    ? mobileSubTitle
                                    : mobileTitle),
                            fontWeight: fontBold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          dokter['data']['pegawai']['kualifikasi_staff']
                              ['nomor_sip'],
                          style: TextStyle(
                            fontSize:
                                Helper.getFontSize(context, mobileOverline),
                            fontWeight: fontNormal,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              _STRCheck(context, STRExpired, dokter),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => onTap(0),
                        child: cardStats(
                            rawatInapText,
                            metrics['pasien_ranap'].toString(),
                            context,
                            STRExpired),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => onTap(1),
                        child: cardStats(
                            rawatJalanText,
                            metrics['pasien_ralan'].toString(),
                            context,
                            STRExpired),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => onTap(2),
                        child: cardStats(
                            jadwalOperasiText,
                            metrics['jadwal_operasi'].toString(),
                            context,
                            STRExpired),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _STRCheck(BuildContext context, double STRExpired, data) {
    return Container(
      margin: EdgeInsets.only(
          top: STRExpired <= STRExpMin ? 10 : 10,
          bottom: STRExpired <= STRExpMin ? 10 : 10),
      padding: STRExpired <= STRExpMin
          ? const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            )
          : const EdgeInsets.all(0),
      width: double.infinity,
      decoration: STRExpired <= STRExpMin
          ? BoxDecoration(
              color: warningColor,
              borderRadius: BorderRadius.circular(5),
            )
          : null,
      child: STRExpired <= STRExpMin
          ? RichText(
              text: TextSpan(
                text: strExpiredIn,
                style: TextStyle(
                  fontSize: Helper.getFontSize(context, mobileCaption),
                  color: textColor,
                ),
                children: [
                  TextSpan(
                    text: " ${STRExpired.toStringAsFixed(1)} $labelBulan",
                    style: TextStyle(
                      fontSize: Helper.getFontSize(context, mobileCaption),
                      color: textColor,
                      fontWeight: fontSemiBold,
                    ),
                  ),
                  TextSpan(
                    text: ". $strRenewText",
                    style: TextStyle(
                      fontSize: Helper.getFontSize(context, mobileCaption),
                      color: textColor,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }
}
