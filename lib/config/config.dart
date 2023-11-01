import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rsiap_dokter/components/List/jadwal_operasi.dart';
import 'package:rsiap_dokter/components/List/pasien_ralan.dart';
import 'package:rsiap_dokter/components/List/pasien_ranap.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/home.dart';
import 'package:rsiap_dokter/screen/list_pasien_radiologi.dart';
import 'package:rsiap_dokter/screen/list_permintaan_radiologi.dart';
import 'package:rsiap_dokter/screen/menu.dart';
import 'package:rsiap_dokter/screen/menu/otp_jasa_medis.dart';
import 'package:rsiap_dokter/screen/menu/pasien_list.dart';
import 'package:rsiap_dokter/screen/menu/pasien_operasi.dart';
import 'package:rsiap_dokter/screen/menu/rekap_kunjungan.dart';
import 'package:rsiap_dokter/screen/profile.dart';

import 'api.dart';

// ==================== App Config ==================== //
String baseUrl = ApiConfig.burl;
String apiUrl = ApiConfig.aurl;
String photoUrl = ApiConfig.purl;
String radiologiUrl = ApiConfig.rau;

// App Content Config
// ignore: non_constant_identifier_names
double STRExpMin = 6;

// App Config
const String appName = 'RSIAP Mobile Dokter';

// =================== End App Config ================== //

// =================== Others Config ==================== //
const int snackBarDuration = 5;
// ================= End Others Config ================== //

// ================ Menu Screen Content ================ //
List menuScreenItems = [
  {
    'label': 'Pasien Rawat Jalan',
    'widget': const PasienList(ralan: true),
    "show_on" : {"spesialis anak", "kebidanan dan kandungan", "dokter umum"},
    'disabled': false
  },
  {
    'label': 'Pasien Rawat Inap',
    'widget': const PasienList(ranap: true),
    "show_on" : {"spesialis anak", "kebidanan dan kandungan", "dokter umum"},
    'disabled': false
  },
  {
    'label': 'Pasien Operasi',
    'widget': const PasienOperasi(),
    "show_on" : {"spesialis anak", "kebidanan dan kandungan"},
    'disabled': false
  },
  {
    'label': 'Rekap Kunjungan Pasien',
    'widget': const RekapKunjunganPasien(),
    "show_on" : {"spesialis anak", "kebidanan dan kandungan", "dokter umum", "spesialis radiologi"},
    'disabled': false
  },
  {
    'label': 'Jasa Medis',
    'widget': OtpJasaMedis(),
    "show_on" : {"spesialis anak", "kebidanan dan kandungan", "dokter umum", "spesialis radiologi"},
    'disabled': false,
  },
  {
    'label': 'Cuti', 
    'widget': "", 
    "show_on" : {"spesialis anak", "kebidanan dan kandungan", "dokter umum", "spesialis radiologi"},
    'disabled': true
  },
  {
    'label': 'Undangan', 
    'widget': "", 
    "show_on" : {"spesialis anak", "kebidanan dan kandungan", "dokter umum", "spesialis radiologi"},
    'disabled': true
  }
];
// ============== End Menu Screen Content ============== //

// ===================================================== //
List tabsHome = [
  {
    "label": rawatInapText,
    "icon": Icons.close,
    "widget": const ListPasienRanap(),
    "show_on": {"spesialis anak", "kebidanan dan kandungan", "dokter umum"}
  },
  {
    "label": rawatJalanText,
    "icon": Icons.close,
    "widget": const ListPasienRalan(),
    "show_on": {"spesialis anak", "kebidanan dan kandungan", "dokter umum"}
  },
  {
    "label": jadwalOperasiText,
    "icon": Icons.close,
    "widget": const ListJadwalOperasi(),
    "show_on": {"spesialis anak", "kebidanan dan kandungan"}
  },
  {
    "label": "Pasien Radiologi",
    "icon": Icons.close,
    "widget": const ListPasienRadiologi(),
    "show_on": {"spesialis radiologi"}
  },
  {
    "label": "Permintaan Radiologi",
    "icon": Icons.close,
    "widget": const ListPermintaanRadiologi(),
    "show_on": {"spesialis radiologi"}
  },
];
// ===================================================== //

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
  }
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
