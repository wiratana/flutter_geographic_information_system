import 'package:flutter/material.dart';
import '../controllers/road_information.dart';

class CompositionProvider extends ChangeNotifier {
  var _fetched_data = null;

  Future fetch() async{
    if(_fetched_data == null){
      this._fetched_data = await RoadInformation().composition();
    }

    return this._fetched_data;
  }
}