import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/auth/UserAuth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  UserAuth _user = UserAuth();
  // final String _verifyToken = "http://10.0.2.2:8000/api/user/verify";
  final String _verifyToken = "https://gmaptest.herokuapp.com/api/user/verify";
  bool _verifyedToken = false;
  int _inticall = 0;
  bool trytoverify = false;
  bool isLogin = false;
  bool isVerifyedToken() {
    return this._verifyedToken;
  }

  AuthProvider() {
    print("inside auth provider");
    // init();
  }

  UserAuth getLoginUser() {
    return this._user;
  }

  bool tryToVerify() {
    return this._verifyedToken;
  }

  String getUserToken() {
    return _user.token;
  }

  Future login() async {
    this._user = await _getUserAuthFromSharedPreferences();
    this.isLogin = true;
  }

  void logout() async {
    this._user = await _setSharedPreNull();

    notifyListeners();
  }

  void init() async {
    _inticall++;
    if (_inticall == 1) {
      this._user = await _verifyTokenFromSharePre(_verifyToken);
      this.trytoverify = true;
      notifyListeners();
      if (this._user.token != null) {
        this.isLogin = true;
        notifyListeners();
      }
    }
  }
}

Future<UserAuth> _verifyTokenFromSharePre(String url) async {
  final UserAuth userdata = await _getUserAuthFromSharedPreferences();
  print("inside auth _verifyTokenFromSharePre ");
  print(userdata.token);
  if (userdata.token != "") {
    return await http.post(url, body: {"token": userdata.token}).then(
        (http.Response response) async {
      final int statusCode = response.statusCode;
      print(response.body);
      print(statusCode);
      if (statusCode == 200) {
        UserAuth user = UserAuth.fromJson(json.decode(response.body));
        return user;
      } else {
        return UserAuth();
      }
    });
  } else {
    return UserAuth();
  }
}

Future _setSharedPreNull() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("user", '');
  prefs.setString("token", '');
  prefs.setString("fullname", '');
  prefs.setString("expires", '');
}

Future<UserAuth> _getUserAuthFromSharedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print("Instance got");
  final String token = prefs.getString('token') ?? '';
  final String user = prefs.getString("user") ?? '';
  final String fullname = prefs.getString("fullname") ?? '';
  final String expires = prefs.getString("expires") ?? '';

  return UserAuth(
      username: user, token: token, fullname: fullname, expires: expires);
}
