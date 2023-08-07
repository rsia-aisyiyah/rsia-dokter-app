import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/utils/fonts.dart';

cardStats(String title, String value, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(15),
    height: MediaQuery.of(context).size.height * 0.13,
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
            fontSize: 16,
            fontWeight: fontNormal,
            color: textWhite,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: fontSemiBold,
            color: textWhite,
          ),
        ),
      ],
    ),
  );
}
