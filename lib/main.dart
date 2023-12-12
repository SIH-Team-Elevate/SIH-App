import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sih_app/pages/authPage.dart';

void main() {
   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);


  @override
  State<MainApp> createState() => _MyAppState();
}
class _MyAppState extends State<MainApp> {
  

  @override
  void initState() {
    super.initState();

  }

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insien E-commerce',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }


}
