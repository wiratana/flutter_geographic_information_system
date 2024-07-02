import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoadInformation{
  Future composition()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/meksisting");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["eksisting"];
    }

    return [];
  }

  Future type()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/mjenisjalan");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["eksisting"];
    }

    return [];
  }

  Future condition()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/mkondisi");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["eksisting"];
    }

    return [];
  }
}