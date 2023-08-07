import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';

loadingku() {
  return Scaffold(
    backgroundColor: bgColor,
    body: SafeArea(
      child: Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    )
  );
}
