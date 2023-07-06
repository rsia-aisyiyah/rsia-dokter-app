import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

cardStatsBg(String title, String value, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Stack(
      children: <Widget>[
        Positioned(
          bottom: -15,
          right: -20,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            child: ClipRRect(
              child: Image.network(
                "https://raw.githubusercontent.com/hungps/flutter_pokedex/master/assets/images/pokeball.png",
                fit: BoxFit.cover,
                color: primaryColor.withOpacity(0.1),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
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
        ),
      ],
    ),
  );
}
