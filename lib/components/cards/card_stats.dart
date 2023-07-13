import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

cardStats(String title, String value, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(15),
    height: MediaQuery.of(context).size.height * 0.12,
    decoration: BoxDecoration(
      color: accentColorDark,
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
            fontWeight: fontWeightNormal,
            color: textColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: fontWeightSemiBold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
