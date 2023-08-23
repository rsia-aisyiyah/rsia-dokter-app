import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/main.dart';
import 'package:rsiap_dokter/screen/menu/jasa_medis.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';

Color accentPurpleColor = Color(0xFF6A53A1);
// Color primaryColor = Color(0xFF121212);
Color accentPinkColor = Color(0xFFF99BBD);
Color accentDarkGreenColor = Color(0xFF115C49);
Color accentYellowColor = Color(0xFFFFB612);
Color accentOrangeColor = Color(0xFFEA7A3B);

class OtpJasaMedis extends StatefulWidget {
  const OtpJasaMedis({super.key});

  @override
  State<OtpJasaMedis> createState() => _OtpJasaMedisState();
}

class _OtpJasaMedisState extends State<OtpJasaMedis> {
  bool isLoading = true;
  String kode = "";
  var _dokter = {};
  var _smtp = {};
  var random = Random().nextInt(8000) + 1000;

  final TextEditingController _otp = TextEditingController();

  void initState() {
    super.initState();
    fetchAllData().then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  // final TextEditingController _mailMessageController = TextEditingController();
  Future<void> fetchAllData() async {
    List<Future> futures = [
      _getDokter(),
      _getSmtp(),
      // _getJadwalOperasiNow(),
    ];

    await Future.wait(futures);
  }

  Future<void> _getDokter() async {
    var res = await Api().getData('/dokter');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      // print(body);
      setState(() {
        _dokter = body;
        // print(_dokter);
      });
    }
  }

  Future<void> _getSmtp() async {
    var res = await Api().getData('/dokter/smtp');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      // print(body);
      setState(() {
        _smtp = body;
        // print(_smtp['data']['email']);
      });
    }
  }

  // Send Mail function
  void cekOtp({
    required String otp,
    // required String mailMessage,
  }) async {
    if (otp == random.toString()) {
      print("OTP SESUAI");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => JasaMedis(),
        ),
      );
    } else {
      showSnackbar('Kode verifikasi salah / tidak berlaku', 'fail');
    }
  }

  void sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    // change your email here
    String username = _smtp['data']['email'].toString();
    // change your password here
    String password = _smtp['data']['password'].toString();
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Mobile Dokter RSIAP')
      ..recipients.add(recipientEmail)
      ..subject = 'Kode Verifikasi Jasa Medis'
      ..text = 'Kode Verifikasi untuk akses ke menu Jasa Medis anda : '
      ..html =
          '<p>Kode Verifikasi untuk akses menu Jasa Medis Anda : </p><h1>$mailMessage<h1>';

    try {
      await send(message, smtpServer);
      showSnackbar('Kode verifikasi terkirim ', 'success');
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? createStyle(Color color) {
      ThemeData theme = Theme.of(context);
      return theme.textTheme.headline3?.copyWith(color: color);
    }

    var otpTextStyles = [
      createStyle(accentPurpleColor),
      createStyle(accentYellowColor),
      createStyle(accentDarkGreenColor),
      createStyle(accentOrangeColor),
    ];
    if (isLoading) {
      return loadingku();
    } else {
      if (random != "") {
        // print(_dokter['data']['pegawai']['npwp']);
        sendMail(
            recipientEmail: _dokter['data']['pegawai']['npwp'].toString(),
            mailMessage: random.toString());
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text('Validasi Data'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    "Cek email anda dan masukkan kode verifikasi pada kolom berikut : "),
                SizedBox(
                  height: 20,
                ),
                OtpTextField(
                  numberOfFields: 4,
                  borderColor: primaryColor,
                  disabledBorderColor: primaryColor,
                  focusedBorderColor: textColor,
                  styles: otpTextStyles,
                  showFieldAsBox: true,
                  borderWidth: 2.0,
                  enabledBorderColor: primaryColor,
                  fieldWidth: 70,
                  //runs when a code is typed in
                  onCodeChanged: (String code) {
                    //handle validation or checks here if necessary
                  },
                  //runs when every textfield is filled
                  onSubmit: (String verificationCode) {
                    kode = verificationCode;
                  },
                ),

                // TextFormField(
                //   keyboardType: TextInputType.number,
                //   maxLength: 4,
                //   controller: _otp,
                //   cursorColor: primaryColor,
                //   decoration: InputDecoration(
                //     labelText: 'Kode Verifikasi',
                //     floatingLabelStyle: TextStyle(color: primaryColor),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //       borderSide: BorderSide(
                //         color: _otp.text.isNotEmpty ? primaryColor : borderGray,
                //         width: 2,
                //       ),
                //     ),
                //     hintStyle: TextStyle(color: borderGray),
                //     focusedBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: primaryColor, width: 2),
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: borderGray, width: 2),
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 30),
                // const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: textWhite,
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      print(kode);
                      cekOtp(
                        otp: kode,
                        // mailMessage: _mailMessageController.text.toString(),
                      );
                    },
                    child: const Text('Submit'),
                  ),
                )
              ],
            ),
          ),
        );
      } else {
        return Scaffold();
      }
    }
  }

  void showSnackbar(String message, String alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: textWhite),
            const SizedBox(width: 10),
            Text(message, style: TextStyle(color: textWhite)),
          ],
        ),
        duration: const Duration(seconds: snackBarDuration),
        backgroundColor: alert == "success" ? primaryColor : errorColor,
      ),
    );
  }
}

void main() {
  var rng = Random();
  // for (var i = 0; i < 10; i++) {
  print(rng.nextInt(8000) + 1000);
  // }
}
