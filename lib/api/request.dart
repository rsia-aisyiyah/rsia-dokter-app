import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rsiap_dokter/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  var token;

  _getToken() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var jsonToken = localStorage.getString('token');
    token = json.decode(jsonToken!);
  }

  auth(data, apiURL) async{
    var fullUrl = apiUrl + apiURL;
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders()
    );
  }

  postData(data, apiURL) async{
    var fullUrl = apiUrl + apiURL;
    await _getToken();
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders()
    );
  }

  postRequest(apiURL) async{
    var fullUrl = apiUrl + apiURL;
    await _getToken();
    return await http.post(
      Uri.parse(fullUrl),
      headers: _setHeaders()
    );
  }

  getData(apiURL) async{
    var fullUrl = apiUrl + apiURL;
    await _getToken();
    return await http.get(
      Uri.parse(fullUrl),
      headers: _setHeaders(),
    );
  }

  _setHeaders() => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
