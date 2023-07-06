import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

createCardPasien(pasien) {
  return Container(
    margin: EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: textColorLight,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(.3),
          blurRadius: 5,
          offset: Offset(0, 3),
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
              pasien.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "lorem ipsum dolor sit amet",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
        Icon(
          Icons.share_outlined,
          color: primaryColor,
        ),
      ],
    ),
  );
}
