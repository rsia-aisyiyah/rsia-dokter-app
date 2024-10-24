import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rsiap_dokter/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // ignore: prefer_typing_uninitialized_variables
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var jsonToken = localStorage.getString('token');
    token = json.decode(jsonToken!);
  }

  auth(data, pathUrl) async {
    var fullUrl = apiUrl + pathUrl;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(pathUrl) async {
    var fullUrl = apiUrl + pathUrl;
    await _getToken();
    return await http.get(
      Uri.parse(fullUrl),
      headers: _setHeaders(),
    );
  }

  postRequest(pathUrl) async {
    var fullUrl = apiUrl + pathUrl;
    await _getToken();
    return await http.post(Uri.parse(fullUrl), headers: _setHeaders());
  }

  postData(data, pathUrl) async {
    var fullUrl = apiUrl + pathUrl;
    await _getToken();
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  getFullUrl(fullUrl) async {
    await _getToken();
    return await http.get(
      Uri.parse(fullUrl.replaceAll('http', 'https')),
      headers: _setHeaders(),
    );
  }

  postFullUrl(data, fullUrl) async {
    await _getToken();
    return await http.post(
      Uri.parse(fullUrl.replaceAll('http', 'https')),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  getDataUrl(String url) async {
    await _getToken();
    return await http.get(
      Uri.parse(url.replaceAll('http', 'https')),
      headers: _setHeaders(),
    );
  }

  _setHeaders() => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
