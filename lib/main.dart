import 'package:flutter_drink_app/Widgets/Root.dart';
import 'package:flutter_drink_app/services/authentication.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Weather App v2',
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: new RootPage(auth: Auth()));
  }
}
