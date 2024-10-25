// sensor.dart
import 'package:rsiap_dokter/config/config.dart';

extension SensorExtension<T> on T {
  String? sensor(int visibleChars) {
    // Periksa apakah aplikasi adalah demo
    if (!isDemo) {
      return this is String ? this as String : null; // Kembalikan null jika bukan String
    }

    // Periksa apakah objek adalah String
    if (this is String) {
      String str = this as String; // Casting ke String
      if (str.length <= visibleChars) {
        return str; // Kembali jika panjang string kurang dari atau sama dengan visibleChars
      }

      String firstVisible = str.substring(0, visibleChars); // Ambil karakter yang terlihat

      // Hitung jumlah karakter yang tidak terlihat (non-space)
      int maskedLength = str.length - visibleChars;
      String maskedPart = '';

      for (int i = visibleChars; i < str.length; i++) {
        maskedPart += (str[i] == ' ') ? ' ' : 'x'; // Tambahkan 'x' jika bukan spasi
      }

      return firstVisible + maskedPart + 'xxx'; // Gabungkan keduanya
    }

    // Kembalikan null jika bukan String
    return null;
  }
}
