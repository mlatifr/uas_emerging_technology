import 'dart:convert';

import 'package:flutter/material.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

String user_id, password, error_login = '';

// void doLogin() async {
//   //nantinya ada pengecekan master_user melalui webservice
//   final prefs = await SharedPreferences.getInstance();
//   prefs.setString("user_id", user_id);
//   main();
// }

void doLogout() async {
  //nantinya ada pengecekan master_user melalui webservice
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("user_id");
  main();
}

class MyLogin extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp(
        title: 'Login page',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Login(),
      );
    } catch (e) {
      print('error karena $e');
    }
  }
}

class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    user_id = 'guest';
    password = 'guest';
  }

  void doLogin() async {
    final response = await http.post(
        // Uri.parse("http://ubaya.prototipe.net/daniel/login.php"),
        Uri.parse(APIurl + "login.php"),
        body: {'user_name': user_id, 'user_password': password});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("user_id", user_id);
        prefs.setString("user_name", json['user_name']);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response.body)));
        main();
      } else {
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(response.body)));
          error_login = "User id atau password error: " + json.toString();
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                initialValue: 'guest',
                onChanged: (value) {
                  user_id = value;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ID: admin',
                    hintText: 'Enter valid email id as abc@gmail.com'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                initialValue: 'guest',
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password:admin',
                    hintText: 'Enter secure password'),
              ),
            ),
            Padding(padding: EdgeInsets.all(10), child: Text(error_login)),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("id: $user_id | passwrod: $password")));

                      APIurl =
                          "http://mlatifr.southeastasia.cloudapp.azure.com/emertech/uas_kuremas/";
                      doLogin();
                    },
                    child: Text(
                      'Login Server',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("id: $user_id | passwrod: $password")));

                      APIurl = "http://192.168.1.7/emertech/uas_kuremas/";
                      doLogin();
                    },
                    child: Text(
                      'Login Local',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
