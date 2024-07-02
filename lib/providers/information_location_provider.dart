import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/location.dart';

class InformationLocationProvider extends ChangeNotifier {
  var _fetched_data = null;

  Future fetch() async{
    if(_fetched_data == null){
      this._fetched_data = await Location().informationLocation();
    }

    return this._fetched_data;
  }
}