import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:provider/provider.dart';

import 'LoginPage.dart';
import '../providers/UserAuth.dart';
import '../screens/HomeScreen.dart';

class MainSplash extends StatefulWidget {
  @override
  _MainSplashState createState() => _MainSplashState();
}

class _MainSplashState extends State<MainSplash> {
  bool darkModeOn;
  @override
  void initState() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    darkModeOn = brightness == Brightness.dark;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: Consumer<UserAuth>(
        builder: (context, auth, _) =>
            auth.user != null ? HomeScreen() : LoginPage(),
      ),
      image: Image.asset("assets/logo.png"),
      backgroundColor:
          darkModeOn ? ThemeData.dark().primaryColor : Colors.white,
      photoSize: MediaQuery.of(context).size.height * 0.29,
      loaderColor: Colors.blue[900],
      loadingText: Text(
        '"United we stand, divided we fall!"',
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
            color: Colors.blue[900]),
        textAlign: TextAlign.center,
      ),
    );
  }
}
