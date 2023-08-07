import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';

class Msg {
  static show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textWhite)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: primaryColor,
      ),
    );
  }

  static success(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textWhite)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: successColor,
      ),
    );
  }

  static info(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textWhite)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: infoColor,
      ),
    );
  }

  static warning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textWhite)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: warningColor,
      ),
    );
  }

  static error(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textWhite)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: errorColor,
      ),
    );
  }
}
