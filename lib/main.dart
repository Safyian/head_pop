import 'package:flutter/material.dart';
import 'package:head_pop/head_pop.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(MaterialApp(
    home: Splash(),
    debugShowCheckedModeBanner: false,
  ));
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: new HeadPopApp(),
      // OnBoard(),
      image: new Image.asset(
        'images/headpop.png',
        fit: BoxFit.fill,
        // width: 200,
        // height: 200,
      ),
      // title: Text(
      //   'Smart Care Dentist',
      //   style: TextStyle(fontSize: 22),
      // ),
      backgroundColor: Colors.white,
      photoSize: 100,
      loaderColor: Colors.green,
    );
  }
}
