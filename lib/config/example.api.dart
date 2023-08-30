class ApiConfig {
  static const String _main = 'http://localhost';
  static const String _burl = '$_main/project_name';
  static const String _purl = '$_main/api/file/pegawai/';
  static const String _aurl = '$_burl/api';

  // getter
  static String get main => _main;
  static String get burl => _burl;
  static String get purl => _purl;
  static String get aurl => _aurl;
}
