import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';

cardStats(String title, String value, BuildContext context, strExp) {
  double h = strExp <= STRExpMin ? 0.12 : 0.14;
  return Container(
    padding: const EdgeInsets.all(15),
    height: MediaQuery.of(context).size.height * h,
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Helper.getFontSize(context, mobileBody),
            fontWeight: fontNormal,
            color: textWhite,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: Helper.getFontSize(context, mobileTitle),
            fontWeight: fontBold,
            color: textWhite,
          ),
        ),
      ],
    ),
  );
}
