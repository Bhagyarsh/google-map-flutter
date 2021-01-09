import 'package:flutter/material.dart';
import 'package:gmap/provider/Location.dart';
import 'package:gmap/screens/PickupLocation.dart';
import 'package:gmap/screens/splash.dart';
import 'package:provider/provider.dart';
import 'provider/User.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: SplashScreen(),
        ));
  }
}
