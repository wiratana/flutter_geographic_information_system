import 'dart:core';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier{
  bool _is_login = false;
  bool get is_login => _is_login;

  String _token = "";

  void set_token(String token){
    _token = token;
    _is_login = true;
    notifyListeners();
  }
}