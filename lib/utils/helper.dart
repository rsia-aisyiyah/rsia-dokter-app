import 'package:rsiap_dokter/config/strings.dart';

class Helper {
  static String getAssetName(String name) {
    return 'assets/images/$name';
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