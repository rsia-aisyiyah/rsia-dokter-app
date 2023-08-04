extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  String capitalizeAll() {
    return this.split(" ").map((str) => str.capitalize()).join(" ");
  }

  String capitalizeFirstOfEach() {
    return this.split(" ")
        .map((str) => str[0].toUpperCase() + str.substring(1))
        .join(" ");
  }

  String getPenjab() {
    return this.toLowerCase().contains('umum') ? 'umum' : 'bpjs';
  }
}
