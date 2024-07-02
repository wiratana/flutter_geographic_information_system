import 'package:flutter/material.dart';
import 'package:geographic_information_system/controllers/auth.dart';
import 'package:geographic_information_system/controllers/location.dart';
import 'package:geographic_information_system/controllers/road.dart';
import 'package:geographic_information_system/controllers/road_information.dart';
import 'package:latlong2/latlong.dart' as latLong;

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    var polylineCoordinates = [latLong.LatLng(0, 1), latLong.LatLng(2, 3), latLong.LatLng(5, 4)];
    return Scaffold(
      body: FutureBuilder(
          // future: Auth().login("andika@gmail.com", "andika"),
          // future: Road().insertRoad(polylineCoordinates, 473, "R1M", "YAMAHA", 3232, 1212, 1, 1, 1, "jagoan"),
          // future: Road().updateRoad(2483, polylineCoordinates, 473, "R1M", "YAMAHA", 3232, 1212, 1, 1, 1, "jagoan"),
          // future: Road().deleteRoad(2482),
        future: Auth().getUser(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              print(snapshot.data);
              return Text("success");
            } else if(snapshot.hasError){
              print(snapshot.error);
              return Text("error");
            } else {
              return Text("loading");
            }
          }
      )
    );
  }
}
