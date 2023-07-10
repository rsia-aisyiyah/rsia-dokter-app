import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rsiap_dokter/screen/index.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:rsiap_dokter/config/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _secureText = true;
  var username, password;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

    var res = await Api().auth(data, '/auth/login');
    var body = json.decode(res.body);

    if (body['success']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', json.encode(body['access_token']));

      Msg.success(context, 'Login success');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const IndexScreen(),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      Msg.error(context, body['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Login",
                  style: TextStyle(
                    color: textColorLight,
                    fontSize: 40,
                    fontWeight: fontWeightBold,
                  ),
                ),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: textColorLight,
                    fontSize: 18,
                    fontWeight: fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: textColorLight,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
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
                            hintStyle: TextStyle(color: secaondaryColorDark),
                          ),
                          style: TextStyle(color: secaondaryColorDark),
                          onSaved: (value) {
                            username = value;
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
                          color: textColorLight,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: TextFormField(
                          maxLines: 1,
                          obscureText: _secureText,
                          style: TextStyle(color: secaondaryColorDark),
                          initialValue: 'dokter123',
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                            hintStyle: TextStyle(color: secaondaryColorDark),
                          ),
                          onSaved: (value) {
                            password = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.06,
                          bottom: MediaQuery.of(context).size.height * 0.04,
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
                              style: TextStyle(color: secaondaryColor),
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
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.3,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "IT RSIA Aisyiyah Pekajangan",
                                style: TextStyle(color: secaondaryColorDark),
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
          )
        ],
      ),
    );
  }
}
