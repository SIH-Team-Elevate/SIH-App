import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sih_app/database/Apis.dart';
import 'package:sih_app/pages/authPage.dart';
import 'package:sih_app/pages/help.dart';
import 'package:sih_app/pages/home.dart';
import 'package:sih_app/pages/loading.dart';
import 'package:sih_app/pages/map.dart';
import 'package:sih_app/pages/moving.dart';
import 'package:sih_app/pages/profile.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = false;
  ApiService apiService = ApiService();
  @override
  void initState() {
    apiService.gettoken().then((value) => {
          if (value != null)
            {
              setState(() {
                loggedIn = true;
              })
            }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insien E-commerce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home:  ProfilePage(),
    );
  }
}
