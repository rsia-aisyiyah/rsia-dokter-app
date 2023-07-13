import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

loadingku(Color color) {
  return Scaffold(
    backgroundColor: backgroundColor,
    body: SafeArea(
      child: Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    )
  );
}
