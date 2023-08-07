import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/config/colors.dart';

class Helper {
  static String getAssetName(String name) {
    return 'assets/images/$name';
  }

  static String getPenjab(String penjab) {
    return penjab.toLowerCase().contains("umum") ? "umum" : "bpjs";
  }

  static String getRealPenjab(penjab) {
    var plow = penjab.toString().toLowerCase();

    if (plow.contains('/')) {
      var p = "BPJS${plow.split('/').last.toUpperCase()}";
      return p;
    } else {
      var p = plow.toUpperCase();
      return p;
    }
  }

  static Color penjabColor(String penjab) {
    return penjab.toLowerCase().contains("bpjs") ? bpjsColor : umumColor;
  }

  static Color penjabOpacityColor(String penjab) {
    return penjab.toLowerCase().contains("bpjs")
        ? bpjsColor.withOpacity(.3)
        : umumColor.withOpacity(.3);
  }

  static String realStatusLanjut(String status) {
    return status.toLowerCase().contains("ralan")
        ? "Rawat Jalan"
        : "Rawat Inap";
  }

  static String formatDate(String date) {
    return DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.parse(date));
  }

  static String greeting() {
    var hour = DateTime.now().hour;

    // pagi
    if (hour < 12) {
      return morningGreeting;
    }
    // siang
    if (hour < 16) {
      return afternoonGreeting;
    }
    // sore
    if (hour < 19) {
      return eveningGreeting;
    }
    // malam
    return nightGreeting;
  }
}
