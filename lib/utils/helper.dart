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

    print("Width: $width");

    // small mobile
    if (width < 320) {
      return size - 2;
    }

    // medium mobile
    if (width < 375) {
      return size;
    }

    // large mobile
    if (width < 425) {
      return size;
    }

    // tablet
    if (width < 768) {
      return size + 2;
    }

    // desktop
    return size + 4;
  }

  // ====================  //

  static String calculateAge(String birthDate) {
    // kalkulasi umur sampai hari ini
    var today = DateTime.now();
    var birth = DateTime.parse(birthDate);

    var age = today.year - birth.year;
    var month = today.month - birth.month;
    var day = today.day - birth.day;

    // misal 1 tahun 3 bulan 4 hari

    if (month < 0) {
      age--;
      month += 12;
    }

    if (day < 0) {
      month--;
      day += 30;
    }

    return "$age tahun $month bulan $day hari";
  }

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

  static String formatDate3(String date) {
    return DateFormat(
      'dd MMM yyyy',
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

  static String numberFormat(number) {
    NumberFormat numberFormat = NumberFormat(
      '#,##0',
      'ID',
    );
    return numberFormat.format(number);
  }

  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }

  static String numToMonth(int month) {
    return DateFormat(
      'MMMM',
      'id_ID',
    ).format(DateTime(0, month));
  }
}
