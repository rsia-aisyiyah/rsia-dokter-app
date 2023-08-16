import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/config/colors.dart';

class Helper {
  static String getAssetName(String name) {
    return 'assets/images/$name';
  }

  //  ====================  //

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

  static Color penjabBgColor(String penjab) {
    return penjab.toLowerCase().contains("bpjs") ? bgBPJS : bgUMUM;
  }

  // ====================  //

  static String realStatusLanjut(String status) {
    return status.toLowerCase().contains("ralan")
        ? "Rawat Jalan"
        : "Rawat Inap";
  }

  // ====================  //

  static double getFontSize(BuildContext context, double size) {
    var width = MediaQuery.of(context).size.width;
    
    // Mobile
    if (width < 768) {
      return size;
    }

    // Tablet
    if (width < 1024) {
      return size + 2;
    }

    // Desktop
    return size + 4;
  }

  // ====================  //

  static String formatDate(String date) {
    return DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.parse(date));
  }

  static String formatDate2(String date) {
    return DateFormat(
      'EEE, dd MMM yyyy',
      'id_ID',
    ).format(DateTime.parse(date));
  }

  // ====================  //

  static String greeting() {
    var hour = DateTime.now().hour;

    if (hour < 12) {
      // Pagi
      return morningGreeting;
    }

    if (hour < 16) {
      // Siang
      return afternoonGreeting;
    }

    if (hour < 19) {
      // Sore
      return eveningGreeting;
    }

    return nightGreeting; // malam
  }
}
