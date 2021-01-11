import 'dart:async';
import 'package:gmap/provider/Location.dart';
import 'package:gmap/provider/User.dart';
import 'package:gmap/screens/PickupLocation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'auth/login.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final userauth = Provider.of<AuthProvider>(context, listen: true);

    SchedulerBinding.instance.addPostFrameCallback((_) => userauth.init());
    if (userauth.trytoverify) {
      if (!userauth.isLogin) {
        Timer(
            Duration(seconds: 1),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) =>
                    ChangeNotifierProvider<AuthProvider>.value(
                      value: userauth,
                     
                      child: LoginPage(),
                    ))));
      } else {
        print(userauth.getUserToken());
        Timer(
            Duration(seconds: 1),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => ChangeNotifierProvider(
                    create: (context) => LocationProvider(),
                    builder: (context, child) => PickupLocation(),
                  ),
                )));
      }
    }
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: 300),
              child: Center(
                child: Text(
                  "Google Map",
                  style: TextStyle(fontSize: 30),
                ),
              )),
          Container(
              margin: EdgeInsets.only(top: 300),
              child: Center(child: CircularProgressIndicator())),
        ],
      )),
    );
  }
}
