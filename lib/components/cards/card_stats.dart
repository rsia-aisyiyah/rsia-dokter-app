import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';

cardStats(BuildContext context, String title, String value) {
  var val = int.parse(value);
  var valFormat = NumberFormat.currency(
    locale: 'id',
    symbol: '',
    decimalDigits: 0,
  ).format(val);

  const padding = 15.0;

  return Container(
    padding: const EdgeInsets.all(padding),
    margin: const EdgeInsets.only(bottom: padding + 5),
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
          maxLines: 2,
          style: TextStyle(
            fontSize: Helper.getFontSize(context, mobileCaption),
            fontWeight: fontNormal,
            color: textWhite,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        Text(
          valFormat,
          style: TextStyle(
            fontSize: Helper.getFontSize(context, mobileBody),
            fontWeight: fontBold,
            color: textWhite,
          ),
        ),
      ],
    ),
  );
}
