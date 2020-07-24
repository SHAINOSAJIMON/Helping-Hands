import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/UserAuth.dart';
import '../providers/user.dart';
import '../screens/UserRequest.dart';

class MainDrawer extends StatelessWidget {
  Widget barApp(IconData icon, String text, BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: MediaQuery.of(context).size.height * 0.02),
        Icon(
          icon,
          color: Colors.blue[900],
        ),
        SizedBox(width: MediaQuery.of(context).size.height * 0.05),
        Text(
          text,
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
              color: Colors.blue[900],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
            child: Image.asset(
              'assets/logo.png',
              height: MediaQuery.of(context).size.height * 0.3,
            ),
          ),
          ListTile(
            title: Text(
              'Hello ${Provider.of<UserProvider>(context).user.name}!',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Divider(),
          ListTile(
            title: barApp(Icons.home, 'Home', context),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Divider(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          ListTile(
            title: barApp(Icons.person, 'My Requests', context),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(UserRequest.routeName);
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Divider(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          ListTile(
            title: barApp(Icons.power_settings_new, 'Log Out', context),
            onTap: () {
              Provider.of<UserAuth>(context, listen: false).logOUt();
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Divider(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.36),
          Center(
            child: Text(
              'Helping Hands\n Version 1.0.0\n ©_ADS',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
