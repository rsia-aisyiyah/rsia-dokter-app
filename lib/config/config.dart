import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rsiap_dokter/screen/home.dart';
import 'package:rsiap_dokter/screen/menu.dart';
import 'package:rsiap_dokter/screen/menu/jasa_medis.dart';
import 'package:rsiap_dokter/screen/menu/otp_jasa_medis.dart';
import 'package:rsiap_dokter/screen/menu/pasien_list.dart';
import 'package:rsiap_dokter/screen/menu/pasien_operasi.dart';
import 'package:rsiap_dokter/screen/menu/rekap_kunjungan.dart';
import 'package:rsiap_dokter/screen/profile.dart';

// ==================== App Config ==================== //

const String baseUrl = 'https://sim.rsiaaisyiyah.com/rsiap-api';
// const String baseUrl = 'http://192.168.100.220/rsiapi';
const String apiUrl = '$baseUrl/api';
const String photoUrl = 'https://sim.rsiaaisyiyah.com/rsiap/file/pegawai/';

// App Content Config
// ignore: non_constant_identifier_names
double STRExpMin = 6;

// App Config
const String appName = 'RSIAP Dokter';
const String appVersion = '1.0.0';

// =================== End App Config ================== //

// =================== Others Config ==================== //

const int snackBarDuration = 5;

// ================= End Others Config ================== //

// ================ Menu Screen Content ================ //

List<Map<String, Object>> menuScreenItems = [
  {
    'label': 'Pasien Rawat Jalan',
    'widget': const PasienList(ralan: true),
    'disabled': false
  },
  {
    'label': 'Pasien Rawat Inap',
    'widget': const PasienList(ranap: true),
    'disabled': false
  },
  {
    'label': 'Pasien Operasi',
    'widget': const PasienOperasi(),
    'disabled': false
  },
  {
    'label': 'Rekap Kunjungan Pasien',
    'widget': const RekapKunjunganPasien(),
    'disabled': false
  },
  {
    'label': 'Jasa Medis',
    'widget': OtpJasaMedis(),
    'disabled': false,
  },
  {'label': 'Cuti', 'widget': "", 'disabled': true},
  {'label': 'Undangan', 'widget': "", 'disabled': true}
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
