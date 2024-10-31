/// NOTE: This is an example file for API configuration
///
/// You need to rename this file to api.dart and fill the variable with your own API URL.
/// If the file is not renamed, the application will not work properly.

class ApiConfig {

  /// Main URL of the API
  static const String _main = 'http://localhost';

  /// Base URL of the API
  static const String _burl = '$_main/project_name';


  /// Pegawai profile picture URL
  static const String _purl = '$_main/api/file/pegawai/';

  /// API URL
  static const String _aurl = '$_burl/api';


  /// Radiologi API URL : this is used for radiologi image assets
  static const String _rau  = '$_main/files/radiologi/';


  // getter
  static String get main => _main;
  static String get burl => _burl;
  static String get purl => _purl;
  static String get aurl => _aurl;
  static String get rau  => _rau;
}
