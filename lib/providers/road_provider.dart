import 'package:flutter/material.dart';
import '../controllers/road.dart';

class RoadProvider extends ChangeNotifier {
  var _fetched_data = null;

  Future fetch() async{
    // if(_fetched_data == null){
    //   this._fetched_data = await Road().getRoad();
    // }
    //
    // return this._fetched_data;
    return await Road().getRoad();
  }
}