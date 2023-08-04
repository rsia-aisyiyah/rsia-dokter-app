import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

class GenTable extends StatelessWidget {
  Map data;

  GenTable({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      textBaseline: TextBaseline.alphabetic,
      children: data.entries.map((e) {
        return TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 5,
                ),
                child: Text(
                  e.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  e.value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
