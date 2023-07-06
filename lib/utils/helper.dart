class Helper {
  static String getAssetName(String name) {
    return 'assets/images/$name';
  }

  static String greeting() {
    var hour = DateTime.now().hour;

    // pagi
    if (hour < 12) {
      return 'Selamat Pagi';
    }
    // siang
    if (hour < 16) {
      return 'Selamat Siang';
    }
    // sore
    if (hour < 19) {
      return 'Selamat Sore';
    }
    // malam
    return 'Selamat Malam';
  }
}