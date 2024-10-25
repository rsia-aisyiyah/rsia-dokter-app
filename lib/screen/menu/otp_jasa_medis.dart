import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/screen/menu/jasa_medis.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/utils/msg.dart';

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
  late Timer? countdownTimer;
  Duration myDuration = Duration(seconds: 60);
  bool isLoading = true;
  bool isLoadingButton = true;
  bool button = true;
  String kode = "";
  var _dokter = {};
  var _smtp = {};
  var random = Random().nextInt(8000) + 1000;

  // final TextEditingController _otp = TextEditingController();

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

  void _activeButton() {
    setState(() {
      button = !button;
    });
  }

  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setCountDown();
    });
  }

  void stopTimer() {
    setState(() {
      countdownTimer!.cancel();
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      myDuration = Duration(seconds: 60);
    });
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    if (mounted) {
      setState(() {
        final seconds = myDuration.inSeconds - reduceSecondsBy;
        print(seconds);
        if (seconds < 0) {
          countdownTimer!.cancel();
          resetTimer();
          _activeButton();
        } else {
          myDuration = Duration(seconds: seconds);
        }
      });
    }
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
      setState(() {
        _dokter = body;
      });
    } else {
      var body = json.decode(res.body);
      Msg.error(context, body['message']);

      setState(() {
        _dokter = {};
        isLoading = false;
      });
    }
  }

  Future<void> _getSmtp() async {
    var res = await Api().getData('/smtp');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      // print(body);
      setState(() {
        _smtp = body;
        // print(_smtp['data']['email']);
      });
    } else {
      var body = json.decode(res.body);
      Msg.error(context, body['message']);

      setState(() {
        _smtp = {};
        isLoading = false;
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
    setState(() {
      isLoadingButton = false;
    });
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
      setState(() {
        isLoadingButton = true;
      });
      _activeButton();
      // resetTimer();
      startTimer();
    } on MailerException catch (e) {
      isLoadingButton = true;
      print('Message not sent.');
      showSnackbar('Format email tidak sesuai ', 'alert');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    // stopTimer();
    TextStyle? createStyle(Color color) {
      ThemeData theme = Theme.of(context);
      return theme.textTheme.displaySmall?.copyWith(color: color);
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
        // sendMail(
        //     recipientEmail: _dokter['data']['pegawai']['npwp'].toString(),
        //     mailMessage: random.toString());
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text('Validasi Data'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(button
                    ? "Dibutuhkan kode verifikasi untuk akses menu Jasa Medis, silahkan klik tombol Kirim Kode Verifikasi dibawah"
                    : "Cek email anda dan masukkan kode verifikasi pada kolom berikut : "),
                SizedBox(
                  height: button ? 0 : 10,
                ),
                button
                    ? Text('')
                    : OtpTextField(
                        numberOfFields: 4,
                        borderColor: primaryColor,
                        disabledBorderColor: primaryColor,
                        focusedBorderColor: textColor,
                        styles: otpTextStyles,
                        showFieldAsBox: true,
                        borderWidth: 2.0,
                        enabledBorderColor: primaryColor,
                        fieldWidth: 55,
                        //runs when a code is typed in
                        onCodeChanged: (String code) {
                          //handle validation or checks here if necessary
                        },
                        //runs when every textfield is filled
                        onSubmit: (String verificationCode) {
                          kode = verificationCode;
                        },
                      ),
                SizedBox(
                  height: button ? 0 : 10,
                ),
                button
                    ? Text('')
                    : RichText(
                        text: TextSpan(
                            style: TextStyle(color: textColor),
                            children: [
                              TextSpan(
                                  text: 'Kirim ulang Kode Verifikasi pada : '),
                              TextSpan(
                                  text: '00:$seconds',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ]),
                      ),

                const SizedBox(height: 20),
                // const SizedBox(height: 30),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    !button
                        ? buttonSubmit()
                        : Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                label: Text(!isLoadingButton
                                    ? ' Mengirim Kode Verifikasi'
                                    : 'Kirim Kode Verifikasi'),
                                icon: !isLoadingButton
                                    ? SizedBox(
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                        width: 25,
                                        height: 25,
                                      )
                                    : Icon(Icons.send),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: textWhite,
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: () {
                                  sendMail(
                                    recipientEmail: _dokter['data']['pegawai']
                                            ['rsia_email_pegawai']['email']
                                        .toString(),
                                    mailMessage: random.toString(),
                                  );
                                },
                                // child: const Text('Kirim Kode Verifikasi'),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        );
      } else {
        return Scaffold();
      }
    }
  }

  Widget buttonVerif() {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          label: Text(!isLoadingButton
              ? ' Mengirim Kode Verifikasi'
              : 'Kirim Kode Verifikasi'),
          icon: !isLoadingButton
              ? SizedBox(
                  child: Center(child: CircularProgressIndicator()),
                  width: 20,
                  height: 20,
                )
              : Icon(Icons.send),
          style: ElevatedButton.styleFrom(
            foregroundColor: textWhite,
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () {
            sendMail(
                recipientEmail: _dokter['data']['pegawai']['rsia_email_pegawai']['email']
                    .toString(),
                mailMessage: random.toString());
          },
          // child: const Text('Kirim Kode Verifikasi'),
        ),
      ),
    );
  }

  Widget buttonSubmit() {
    return Expanded(
      child: SizedBox(
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
          onPressed: button
              ? null
              : () {
                  print(kode);
                  cekOtp(
                    otp: kode,
                    // mailMessage: _mailMessageController.text.toString(),
                  );
                },
          // onPressed: () {
          //   print(kode);
          //   cekOtp(
          //     otp: kode,
          //     // mailMessage: _mailMessageController.text.toString(),
          //   );
          // },
          child: const Text('Submit'),
        ),
      ),
    );
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
