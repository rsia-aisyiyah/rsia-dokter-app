import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';

class Msg {
  static show(BuildContext context, String message) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Expanded(child: Text(message, style: TextStyle(color: textWhite))),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: primaryColor,
      ),
    );
  }

  static success(BuildContext context, String message) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: textWhite),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: textWhite))),
          ],
        ),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: successColor,
      ),
    );
  }

  static info(BuildContext context, String message) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: textWhite),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: textWhite))),
          ],
        ),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: infoColor,
      ),
    );
  }

  static warning(BuildContext context, String message) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_outlined, color: textWhite),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: textWhite))),
          ],
        ),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: warningColor,
      ),
    );
  }

  static error(BuildContext context, String message) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: textWhite),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: textWhite))),
          ],
        ),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: errorColor,
      ),
    );
  }

  static withData(
    BuildContext context,
    String category,
    String message,
    Icon icon,
    Map dataForTable,
  ) {
    Color color;
    switch (category) {
      case 'success':
        color = successColor;
        break;

      case 'info':
        color = infoColor;
        break;

      case 'warning':
        color = warningColor;
        break;

      case 'error':
        color = errorColor;
        break;

      default:
        color = primaryColor;
    }

    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Helper.getFontSize(context, 18),
                    fontWeight: fontBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GenTable(data: dataForTable)
          ],
        ),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: color,
      ),
    );
  }
}
