import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

cardStats(String title, String value) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: fontWeightNormal,
            color: textColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: fontWeightSemiBold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
