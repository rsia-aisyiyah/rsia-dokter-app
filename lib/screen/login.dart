import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/screen/index.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _secureText = true;
  var username = '';
  var password = '';  
  
  final _formKey = GlobalKey<FormState>();

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    if (username.isEmpty) {
      Msg.error(context, 'Username tidak boleh kosong');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password.isEmpty) {
      Msg.error(context, 'Password tidak boleh kosong');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var data = {
      'username': username,
      'password': password,
    };

    await Api().auth(data, '/auth/login').then((res) {
      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        if (body['success']) {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('token', json.encode(body['access_token']));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const IndexScreen(),
              ),
            );
          });
        } else {
          Msg.error(context, body['message']);
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        Msg.error(
          context,
          'Username atau password salah, atau terdapat kesalahan pada sistem',
        );
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash-bg.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Image.asset(
                    'assets/images/logo-text-rsiap2.png',
                    height: 150,
                    width: 150,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: TextFormField(
                            maxLines: 1,
                            initialValue: '1.101.1112',
                            decoration: InputDecoration(
                              hintText: "Username",
                              contentPadding: const EdgeInsets.all(10),
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: textColor),
                            ),
                            style: TextStyle(color: textColor),
                            onSaved: (value) {
                              username = value!;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: TextFormField(
                            maxLines: 1,
                            obscureText: _secureText,
                            style: TextStyle(color: textColor),
                            initialValue: 'dokter123',
                            decoration: InputDecoration(
                              hintText: "Password",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(10),
                              hintStyle: TextStyle(color: textColor),
                            ),
                            onSaved: (value) {
                              password = value!;
                            },
                          ),
                        ),
                        isKeyboard
                            ? const SizedBox(height: 50)
                            : Padding(
                                padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.06,
                                  bottom:
                                      MediaQuery.of(context).size.height * 0.04,
                                ),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Msg.info(
                                        context,
                                        'Silahkan hubungi tim IT untuk reset password',
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _login();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 20,
                              ),
                            ),
                            child: Text(
                              _isLoading ? 'Processing...' : 'Login',
                              style: TextStyle(
                                color: textColorLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isKeyboard
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 5),
              child: Text(
                "IT RSIA Aisyiyah Pekajangan",
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor.withOpacity(0.6)),
              ),
            ),
    );
  }
}
