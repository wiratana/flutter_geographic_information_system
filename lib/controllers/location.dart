import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Location{
  Future informationLocation()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/mregion");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result;
    }

    return [];
  }

  Future province(id)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/provinsi/${id}");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["provinsi"] ?? [];
    }

    return [];
  }

  Future district(id)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/kabupaten/${id}");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["kabupaten"] ?? [];
    }

    return [];
  }

  Future subDistrict(id)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/kecamatan/${id}");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["kecamatan"] ?? [];
    }

    return [];
  }

  Future village(id)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/desa/${id}");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["desa"] ?? [];
    }

    return [];
  }
}