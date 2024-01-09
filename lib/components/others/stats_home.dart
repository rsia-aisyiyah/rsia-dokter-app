import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rsiap_dokter/components/blur.dart';
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
  final List filteredTabs;

  const StatsHomeWidget({
    super.key,
    this.dokter,
    this.metrics,
    required this.onTap,
    this.filteredTabs = const [],
  });

  double monthBetween(DateTime endDate) {
    var now = DateTime.now();
    var difference = endDate.difference(now).inDays;
    var month = difference / 30;
    return month;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];

    if (filteredTabs.isNotEmpty) {
      for (var i = 0; i < filteredTabs.length; i++) {
        final index = i;
        final label = filteredTabs[i]['label'];

        cards.add(
          Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: cardStats(
                context,
                label,
                metrics[label.toLowerCase().replaceAll(" ", "_")].toString(),
              ),
            ),
          ),
        );

        if (i < filteredTabs.length - 1) {
          cards.add(const SizedBox(width: 10));
        }
      }
    }

    var STRExpired = monthBetween(DateTime.parse(
      dokter['data']['pegawai']['kualifikasi_staff_klinis']['tanggal_akhir_str'],
    ));

    String photoFile = dokter['data']['pegawai']['photo'].toString();

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(15),
      // margin: const EdgeInsets.only(bottom: 25),
      child: SafeArea(
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
                    child: photoFile.isNotEmpty ? CachedNetworkImage(
                      imageUrl: photoUrl + photoFile,
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
                        color: Colors.grey[400],
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ) : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[400],
                      child: const Icon(Icons.image_not_supported_outlined),
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
                          fontSize: Helper.getFontSize(context, mobileCaption),
                          fontWeight: fontNormal,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dokter['data']['nm_dokter'],
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: Helper.getFontSize(context, mobileTitle),
                          overflow: TextOverflow.ellipsis,
                          fontWeight: fontBold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      BlurWidget(
                        applyBlur: false,
                        child: Text(
                          dokter['data']['pegawai']['kualifikasi_staff_klinis']['nomor_sip'],
                          style: TextStyle(
                            fontSize: Helper.getFontSize(context, mobileOverline),
                            fontWeight: fontNormal,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            _STRCheck(context, STRExpired, dokter),
            filteredTabs.isNotEmpty
              ? Expanded(
                  child: Row(
                    children: cards,
                  ),
                )
              : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Container _STRCheck(BuildContext context, double STRExpired, data) {
    return Container(
      margin: EdgeInsets.only(
        top: STRExpired <= STRExpMin ? 10 : 10,
        bottom: STRExpired <= STRExpMin ? 10 : 10,
      ),
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
                  fontSize: Helper.getFontSize(context, mobileOverline),
                  color: textColor,
                ),
                children: [
                  TextSpan(
                    text: " ${STRExpired.toStringAsFixed(1)} $labelBulan",
                    style: TextStyle(
                      fontSize: Helper.getFontSize(context, mobileOverline),
                      color: textColor,
                      fontWeight: fontSemiBold,
                    ),
                  ),
                  TextSpan(
                    text: ". $strRenewText",
                    style: TextStyle(
                      fontSize: Helper.getFontSize(context, mobileOverline),
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
