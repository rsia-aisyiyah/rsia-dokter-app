import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';

class createCardJasaMedis extends StatefulWidget {
  final Map dataJasaMedis;
  const createCardJasaMedis({
    super.key,
    required this.dataJasaMedis,
    // required this.dataJasaMedis,
  });

  @override
  State<createCardJasaMedis> createState() => _createCardJasaMedisState();
}

class _createCardJasaMedisState extends State<createCardJasaMedis> {
  // IconData _currentIcon = Icons.star; // Initial icon
  bool showIcon = true;
  void _changeIcon() {
    setState(() {
      showIcon = !showIcon;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        Helper.numToMonth(
                                int.parse(widget.dataJasaMedis['bulan'])) +
                            " " +
                            widget.dataJasaMedis['bulan'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: fontSemiBold,
                        ),
                      ),
                      Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                _changeIcon();
                              },
                              icon: Icon(showIcon
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GenTable(
                    data: {
                      nominalText: showIcon ? "* * * * *" : Helper.numberFormat(
                        widget.dataJasaMedis['jm_dokter'],
                      ),
                      tambahanText: showIcon ? "* * * * *" : "( + ) " + Helper.numberFormat(
                        widget.dataJasaMedis['tambahan'],
                      ),
                      potonganText: showIcon ? "* * * * *" : "( - ) " + Helper.numberFormat(
                        widget.dataJasaMedis['potongan'],
                      ),
                      jasaMedisText: showIcon ? "* * * * *" : Helper.numberFormat(
                        widget.dataJasaMedis['jm_diterima'],
                      ),
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
}
