import 'dart:async';

import 'package:disaster_reporting/providers/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:hardware_buttons/hardware_buttons.dart' as HardwareButtons;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import '../providers/user.dart';
import '../providers/UserAuth.dart';
import './AddRequest.dart';
import '../widget/MainDrawer.dart';
import './UserRequest.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isInit = true;
  bool darkModeOn;
  bool isLoading = false;
  StreamSubscription _volumeButtonSubscription;
  Map<String, bool> selectors = {
    'All Departments': true,
    'Police': false,
    'Administration': false,
    'KSEB': false,
    'KWA': false,
    'Fire & Rescue': false,
    'Evacuation': false,
    'Volunteer': false,
    'PWD': false,
    'Other': false,
    'SOS': false,
  };

  @override
  void initState() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    darkModeOn = brightness == Brightness.dark;
    _volumeButtonSubscription =
        HardwareButtons.volumeButtonEvents.listen((event) {
      if (event == HardwareButtons.VolumeButtonEvent.VOLUME_UP) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Are you sure?'),
                  content: Text('Are you sure you want to make an SOS call?'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    FlatButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        Navigator.of(context).pop();
                        String location;
                        final geolocator = Geolocator();
                        Position position = await geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high);
                        List<Placemark> placemark = await Geolocator()
                            .placemarkFromCoordinates(
                                position.latitude, position.longitude,
                                localeIdentifier: 'en');

                        placemark.forEach((element) {
                          location =
                              '${element.name}  ${element.thoroughfare}  ${element.subLocality}-${element.postalCode}  ${element.locality}  ${element.administrativeArea}  ${element.country}';
                        });
                        final userDetails =
                            Provider.of<UserProvider>(context, listen: false)
                                .user;
                        final dateTime =
                            '${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jms().format(DateTime.now())}';
                        final _postDetails = Post(
                          dateTime: dateTime,
                          description:
                              'SOS call! Please help me at the location provided ASAP.',
                          userId: userDetails.userId,
                          district: userDetails.district,
                          familyMembers: userDetails.family,
                          image: null,
                          location: location,
                          reacted: [],
                          type: 'SOS',
                          name: userDetails.name,
                          phNumber: userDetails.phnumber,
                        );
                        Provider.of<PostProvider>(context, listen: false)
                            .addPost(_postDetails)
                            .then((value) {
                          setState(() {
                            isLoading = false;
                          });
                          if (value) {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Request Posted Successfully'),
                                content: Text(
                                    'Your SOS request has been submitted successfully, please delete the request after your need is fulfilled.'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text('Okay'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Couldn\'t post your request!'),
                                content: Text(
                                    'Your request was not processed, please check your internet connection or try again later.'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text('Okay'),
                                  ),
                                ],
                              ),
                            );
                          }
                        });
                      },
                      child: Text('Yes'),
                    ),
                  ],
                ));
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      Provider.of<UserProvider>(context, listen: false)
          .getUserDetails(
        Provider.of<UserAuth>(context, listen: false).user.email,
      )
          .then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _volumeButtonSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            darkModeOn ? ThemeData.dark().primaryColor : Colors.white,
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(UserRequest.routeName);
              },
              child: Icon(
                Icons.person,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
        title: Text(
          'Helping Hands',
          style: GoogleFonts.doHyeon(
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                letterSpacing: 2,
                color: Colors.blue[900]),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<PostProvider>(
              builder: (context, post, child) => Stack(
                children: <Widget>[
                  StreamBuilder<QuerySnapshot>(
                    stream: post.query,
                    builder: (context, snapshot) => snapshot.hasData
                        ? ListView.builder(
                            padding: EdgeInsets.only(top: 40),
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (ctx, index) => Container(
                              padding: EdgeInsets.all(30.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 20,
                                child: Column(children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            snapshot.data.documents[index]
                                                ['name'],
                                            style: GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          snapshot.data.documents[index]
                                              ['dateTime'],
                                          style: GoogleFonts.quicksand(
                                            textStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      child: snapshot.data.documents[index]
                                                  ['image'] ==
                                              'sos'
                                          ? Image.asset('assets/SOS.jpg')
                                          : snapshot.data.documents[index]
                                                      ['image'] ==
                                                  'none'
                                              ? Image.asset(
                                                  'assets/placeholder.png')
                                              : FadeInImage(
                                                  placeholder: AssetImage(
                                                      'assets/placeholder.png'),
                                                  image: NetworkImage(
                                                    snapshot.data
                                                            .documents[index]
                                                        ['image'],
                                                  ),
                                                  fit: BoxFit.contain,
                                                )),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(
                                        Icons.message,
                                        size: 40.0,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          child: Text(
                                            snapshot.data.documents[index]
                                                ['description'],
                                            softWrap: true,
                                            style: GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        size: 45.0,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        child: Text(
                                          snapshot.data.documents[index]
                                              ['location'],
                                          softWrap: true,
                                          style: GoogleFonts.quicksand(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 25.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.portrait
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.026
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                        ),
                                        CircleAvatar(
                                          child: Text(
                                            snapshot
                                                .data
                                                .documents[index]['reacted']
                                                .length
                                                .toString(),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.grey,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                        Text(
                                          ' persons reacted',
                                          style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.015),
                                  snapshot.data.documents[index]['userId'] !=
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .user
                                              .userId
                                      ? SizedBox(
                                          width: 300,
                                          child: RaisedButton(
                                            color: Colors.blue[900],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text('Are you sure?'),
                                                  content: Text(
                                                      'Are you sure you want to react to this post as this action cannot be undone and there are lives at stake?'),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(ctx).pop();
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    FlatButton(
                                                      child: Text("Yes"),
                                                      onPressed: () {
                                                        Navigator.of(ctx).pop();
                                                        Provider.of<PostProvider>(
                                                                context,
                                                                listen: false)
                                                            .react(
                                                                snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .documentID,
                                                                Provider.of<UserProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .user
                                                                    .userId)
                                                            .then((value) {
                                                          if (value ==
                                                              'success') {
                                                            showDialog(
                                                              context: context,
                                                              builder: (ctx) =>
                                                                  AlertDialog(
                                                                title: Text(
                                                                    'You have reacted successfully'),
                                                                content: Text(
                                                                    'You have reacted succefully to help the requestor.Do not forget as many lives are at stake!'),
                                                                actions: <
                                                                    Widget>[
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.of(
                                                                              ctx)
                                                                          .pop();
                                                                      await FlutterPhoneDirectCaller
                                                                          .callNumber(
                                                                              '${snapshot.data.documents[index]['phNumber']}');
                                                                    },
                                                                    child: Text(
                                                                        'Okay'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } else if (value ==
                                                              'already there') {
                                                            showDialog(
                                                              context: context,
                                                              builder: (ctx) =>
                                                                  AlertDialog(
                                                                title: Text(
                                                                    'You have already reacted!'),
                                                                content: Text(
                                                                    'You have already reacted to this request post!'),
                                                                actions: <
                                                                    Widget>[
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.of(
                                                                              ctx)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        'Okay'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            showDialog(
                                                              context: context,
                                                              builder: (ctx) =>
                                                                  AlertDialog(
                                                                title: Text(
                                                                    'An error occured!'),
                                                                content: Text(
                                                                    'You couldn\'t react to the post due to some error. Please check your internet connection or try again!'),
                                                                actions: <
                                                                    Widget>[
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.of(
                                                                              ctx)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        'Okay'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }
                                                        });
                                                      },
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'React and Call',
                                              style: GoogleFonts.openSans(
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.015,
                                  ),
                                ]),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              'No Requests Yet !',
                            ),
                          ),
                  ),
                  child
                ],
              ),
              child: Container(
                color:
                    darkModeOn ? ThemeData.dark().primaryColor : Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['All Departments']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['All Departments']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['All Departments']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getAllPost();
                                selectors = {
                                  'All Departments': true,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'All Departments',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['All Departments']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['All Departments']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['SOS']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['SOS']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['SOS']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('SOS');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': true,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'SOS',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['SOS']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['SOS']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['Police']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['Police']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['Police']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('Police');
                                selectors = {
                                  'All Departments': false,
                                  'Police': true,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'Police',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['Police']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['Police']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['Administration']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['Administration']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['Administration']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('District Administration');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': true,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'Administration',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['Administration']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['Administration']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['KSEB']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['KSEB']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['KSEB']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('KSEB');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': true,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'KSEB',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['KSEB']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['KSEB']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['KWA']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['KWA']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['KWA']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('Kerala Water Authority');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': true,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'KWA',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['KWA']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['KWA']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['Fire & Rescue']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['Fire & Rescue']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['Fire & Rescue']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('Fire and Rescue');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': true,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'Fire & Rescue',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['Fire & Rescue']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['Fire & Rescue']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['Evacuation']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['Evacuation']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['Evacuation']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('Evacuation Team');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': true,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'Evacuation',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['Evacuation']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['Evacuation']
                                            ? Colors.white
                                            : Colors.blue[900],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['Volunteer']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['Volunteer']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['Volunteer']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('Volunteer');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': true,
                                  'PWD': false,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'Volunteer',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['Volunteer']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['Volunteer']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['PWD']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['PWD']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['PWD']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('PWD');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': true,
                                  'Other': false,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'PWD',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['PWD']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['PWD']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                        padding: EdgeInsets.all(8),
                        height: 60,
                        width: 150,
                        child: Card(
                          color: darkModeOn
                              ? selectors['Other']
                                  ? Colors.white
                                  : Colors.blue[900]
                              : selectors['Other']
                                  ? Colors.blue[900]
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: darkModeOn
                                  ? selectors['Other']
                                      ? Colors.blue[900]
                                      : Colors.white
                                  : Colors.blue[900],
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            highlightColor: Colors.blue[700],
                            onTap: () {
                              setState(() {
                                Provider.of<PostProvider>(context,
                                        listen: false)
                                    .getPost('Others');
                                selectors = {
                                  'All Departments': false,
                                  'Police': false,
                                  'Administration': false,
                                  'KSEB': false,
                                  'KWA': false,
                                  'Fire & Rescue': false,
                                  'Evacuation': false,
                                  'Volunteer': false,
                                  'PWD': false,
                                  'Other': true,
                                  'SOS': false,
                                };
                              });
                            },
                            child: Center(
                              child: Text(
                                'Other',
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: darkModeOn
                                        ? selectors['Other']
                                            ? Colors.blue[900]
                                            : Colors.white
                                        : selectors['Other']
                                            ? Colors.white
                                            : Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        onPressed: () {
          Navigator.of(context).pushNamed(AddRequest.routeName);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      drawer: MainDrawer(),
    );
  }
}
