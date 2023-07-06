import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

class Msg {
  show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColorLight)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: primaryColor,
      ),
    );
  }

  success(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColorLight)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: successColor,
      ),
    );
  }

  info(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColorLight)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: infoColor,
      ),
    );
  }

  warning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColorLight)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: warningColor,
      ),
    );
  }

  error(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColorLight)),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: errorColor,
      ),
    );
  }
}
