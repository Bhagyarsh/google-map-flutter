import 'dart:convert';
import 'package:gmap/provider/Location.dart';
import 'package:gmap/provider/User.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth/UserAuth.dart';
import '../PickupLocation.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

void showDialogSingleButton(
    BuildContext context, String title, String message, String buttonLabel) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(buttonLabel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future _saveuserinfologin(model) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("user", model.username);
  prefs.setString("token", model.token);
  prefs.setString("fullname", model.fullname);
  prefs.setString("expires", model.expires);
}

class _LoginPageState extends State<LoginPage> {
  bool _vaildlogin = false;
  // String url = "http://10.0.2.2:8000/api/user";
  String url = "http://192.168.1.103:8000/api/user";
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  Map data;
  Future<UserAuth> login(BuildContext context, String url, dynamic data) async {
    return await http.post(url, body: data)
        // ignore: missing_return
        .then((http.Response response) async {
      final int statusCode = response.statusCode;
      print(response.body);
      print(statusCode);

      if (statusCode == 200) {
        setState(() {
          _vaildlogin = true;
        });
        final UserAuth model = UserAuth.fromJson(json.decode(response.body));
        await _saveuserinfologin(model);

        return model;
      }
      if (statusCode < 200 || statusCode >= 400 || json == null) {
        showDialogSingleButton(
            context,
            "Unable to Login",
            "You may have supplied an invalid 'Username' / 'Password' combination. Please try again or contact your support representative.",
            "OK");
        return UserAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userauth = Provider.of<AuthProvider>(context, listen: true);

    final username = TextEditingController();
    final password = TextEditingController();
    final emailornumberField = TextFormField(
      obscureText: false,
      style: style,
      controller: username,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "username",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter username';
        }
        return null;
      },
    );
    final passwordField = TextFormField(
      obscureText: true,
      style: style,
      controller: password,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "password   *",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter password';
        }
        return null;
      },
    );

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          print("inside login");

          print({
            "username": username.text.trim(),
            "password": password.text.trim()
          });
          login(context, url, {
            "username": username.text.trim(),
            "password": password.text.trim()
          }).then((value) {
            print(value);
            if (value.token != null) {
              userauth.login();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => ChangeNotifierProvider(
                  create: (context) => LocationProvider(),
                  builder: (context, child) => PickupLocation(),
                ),
              ));
            }
          });
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: Form(
            child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30),
            ),
            Container(height: 50, child: emailornumberField),
            Padding(
              padding: const EdgeInsets.all(10),
            ),
            Container(height: 50, child: passwordField),
            Padding(
              padding: const EdgeInsets.all(10),
            ),
            Container(height: 50, child: loginButon),
            Padding(
              padding: const EdgeInsets.all(30),
            ),
            Center(
              child: GestureDetector(
                  onTap: () {
                    // print("register");
                    // Navigator.pushReplacementNamed(
                    //   context,
                    //   "/register",
                    // );
                  },
                  child: const Text("Register here!")),
            ),
          ],
        )));
  }
}
