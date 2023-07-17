import 'dart:math';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';
import 'package:rsiap_dokter/screen/home.dart';
import 'package:rsiap_dokter/screen/menu.dart';
import 'package:rsiap_dokter/screen/profile.dart';
import 'package:rsiap_dokter/utils/msg.dart';

// ==================== App Config ==================== //

const String baseUrl = 'https://sim.rsiaaisyiyah.com/rsiap-api';
const String apiUrl = '$baseUrl/api';
String jwtSignature = randomString(32);

// App Content Config
double STRExpMin = 6;

// App Config
const String appName = 'RSIAP Dokter';
const String appVersion = '1.0.0';

// =================== End App Config ================== //



// =================== Color Config ==================== //

Color accentColor = HexColor('#23c799');
Color primaryColor = HexColor('#2bdaa8');
Color secondaryColor = HexColor('#cbf6ea');

Color successColor = Colors.teal;
Color warningColor = Colors.orange;
Color errorColor = Colors.pink;
Color infoColor = Colors.blue;

Color backgroundColor = HexColor('#d8f8ef');
Color backgroundColorDark = Colors.grey[900]!;

Color textColor = HexColor("#020d0a");
Color textColorLight = HexColor("#ffffff");

FontWeight fontWeightLight = FontWeight.w300;
FontWeight fontWeightNormal = FontWeight.w400;
FontWeight fontWeightMedium = FontWeight.w500;
FontWeight fontWeightSemiBold = FontWeight.w600;
FontWeight fontWeightBold = FontWeight.w700;

// ================== End Color Config=================== //



// =================== Others Config ==================== //

const int snackBarDuration = 2;

// ================= End Others Config ================== //



// ================ Menu Screen Content ================ //

List<Map<String, Object>> menuScreenItems = [
  {
    'label': 'Pasien Rawat Jalan',
    'widget': ""
  },
  {
    'label': 'Pasien Rawat Inap',
    'widget': ""
  },
  {
    'label': 'Pasien Operasi',
    'widget': ""
  },
  {
    'label': 'Rekap Kunjungan Pasien',
    'widget': ""
  },
  {
    'label': 'Jasa Medis',
    'widget': ""
  },
  {
    'label': 'Cuti',
    'widget': ""
  },
  {
    'label': 'Undangan',
    'widget': ""
  }
];

// ============== End Menu Screen Content ============== //



// =============== Bottom Navigation Bar ================ //

const List<Map<String, Object>> navigationItems = [
  {
    'icon': Icons.home,
    'label': 'Home',
    'widget': HomePage(),
  },
  {
    'icon': Icons.grid_view_rounded,
    'label': 'Menu',
    'widget': MenuPage(),
  },
  {
    'icon': Icons.person,
    'label': 'Profile',
    'widget': ProfilePage(),
  },
];

// ============= End Bottom Navigation Bar ============== //



// ================ Function Random String ============== //
String randomString(int length) {
  var rand = Random();
  var codeUnits = List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return String.fromCharCodes(codeUnits);
}