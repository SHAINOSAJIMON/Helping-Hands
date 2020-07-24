import 'package:disaster_reporting/screens/LoginPage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import './providers/post.dart';
import './providers/user.dart';
import './providers/UserAuth.dart';
import './screens/SignUp.dart';
import './screens/AddRequest.dart';
import './screens/HomeScreen.dart';
import './screens/MainSplash.dart';
import './screens/UserRequest.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UserAuth(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PostProvider(),
        ),
      ],
      child: MaterialApp(
          title: 'FloodApp',
          theme: ThemeData(
            primaryColor: Colors.blue[900],
            accentColor: Colors.blue[800],
            appBarTheme: AppBarTheme(
              elevation: 0,
              color: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.blue[900],
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.blue[900],
            appBarTheme: AppBarTheme(
              elevation: 0,
              color: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.blue[900],
              ),
            ),
          ),
          routes: {
            LoginPage.routeName: (ctx) => LoginPage(),
            HomeScreen.routeName: (ctx) => HomeScreen(),
            SignUp.routeName: (ctx) => SignUp(),
            AddRequest.routeName: (ctx) => AddRequest(),
            UserRequest.routeName: (ctx) => UserRequest(),
          },
          home: MainSplash()),
    );
  }
}
