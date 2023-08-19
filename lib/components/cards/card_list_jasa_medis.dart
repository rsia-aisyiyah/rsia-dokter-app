import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';

createCardJasaMedis(jasamedis) {
  var seticon = "true";

  return Column(
    children: [
      Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: 25,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Helper.penjabColor("bpjs"),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Helper.penjabOpacityColor("bpjs"),
                  blurRadius: 5,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Helper.numToMonth(int.parse(jasamedis['bulan'])) +
                          " " +
                          jasamedis['tahun'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: fontSemiBold,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            seticon == true
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GenTable(
                  data: {
                    nominalText: Helper.numberFormat(jasamedis['jm_dokter']),
                    tambahanText:
                        '(+) ' + Helper.numberFormat(jasamedis['tambahan']),
                    potonganText:
                        '(-) ' + Helper.numberFormat(jasamedis['potongan']),
                    jasaMedisText:
                        Helper.numberFormat(jasamedis['jm_diterima']),
                  },
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: fontSemiBold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
    ],
  );
}
