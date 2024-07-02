import 'dart:convert';
import 'dart:ui';
import 'dart:html';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth{
  Future register(name, email, password) async{
    var url = Uri.https("gisapis.manpits.xyz", "/api/register");
    var response = await http.post(
        url,
        body:{
          'name': name.toString(),
          'email': email.toString(),
          'password': password.toString()
        });

    if(response.statusCode == 200){
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["meta"]["data"] ?? [];
    }

    return [];
  }

  Future login(email, password) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "/api/login");
    var response = await http.post(url, body: {
      "email": email.toString(),
      "password": password.toString()
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      prefs.setString("token", result["meta"]["token"]);
      return result["meta"]["token"];
    }

    return [];
  }

  Future logout() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "/api/logout");
    var response = await http.post(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["meta"]["token"] ?? [];
    }

    return [];
  }

  Future getUser() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/user");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["data"]["user"] ?? [];
    }

    return [];
  }
}