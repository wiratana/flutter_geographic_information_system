import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latLng;

class Road{
  Future insertRoad(polyline, id_village, code, name, range, wide, id_composition, id_condition, id_type, description)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var url = Uri.https("gisapis.manpits.xyz", "api/ruasjalan");
    var response = await http.post(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    }, body: {
      "paths": polyline.toString(),
      "desa_id": id_village.toString(),
      "kode_ruas": code.toString(),
      "nama_ruas": name.toString(),
      "panjang": range.toString(),
      "lebar": wide.toString(),
      "eksisting_id": id_composition.toString(),
      "kondisi_id": id_condition.toString(),
      "jenisjalan_id": id_type.toString(),
      "keterangan": description.toString()
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["ruasjalan"] ?? [];
    }

    return [];
  }

  Future getRoad() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/ruasjalan");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["ruasjalan"] ?? [];
    }

    return [];
  }

  Future getRoadById(id) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/ruasjalan/${id}");
    var response = await http.get(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });
    print(response.body);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["ruasjalan"] ?? [];
    }

    return [];
  }

  Future updateRoad(id, polylineCoordinates, id_village, code, name, range, wide, id_composition, id_condition, id_type, description)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/ruasjalan/${id}");
    var response = await http.put(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    }, body: {
      "paths": polylineCoordinates.toString(),
      "desa_id": id_village.toString(),
      "kode_ruas": code.toString(),
      "nama_ruas": name.toString(),
      "panjang": range.toString(),
      "lebar": wide.toString(),
      "eksisting_id": id_composition.toString(),
      "kondisi_id": id_condition.toString(),
      "jenisjalan_id": id_type.toString(),
      "keterangan": description.toString()
    });
    print(response.body);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["ruasjalan"] ?? [];
    }

    return [];
  }

  Future deleteRoad(id)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.https("gisapis.manpits.xyz", "api/ruasjalan/${id}");
    var response = await http.delete(url, headers: {
      "Authorization": "Bearer ${prefs.getString("token")}"
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      return result["ruasjalan"] ?? [];
    }

    return [];
  }
}