import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/post.dart';
import '../providers/user.dart';

class UserRequest extends StatefulWidget {
  static const routeName = '/UserRequest';
  @override
  _UserRequestState createState() => _UserRequestState();
}

class _UserRequestState extends State<UserRequest> {
  bool isLoading = false;
  bool isInit = true;
  List<DocumentSnapshot> post;
  @override
  void initState() {
    didChangeDependencies();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      isInit = false;
      String userId =
          Provider.of<UserProvider>(context, listen: false).user.userId;
      Provider.of<PostProvider>(context, listen: false)
          .getUserPost(userId)
          .then((value) {
        setState(() {
          isLoading = false;
        });

        if (value == null) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('An error occured'),
              content: Text(
                  'Something went wrong, please check your internet connect or try again'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('Okay'),
                )
              ],
            ),
          );
        }
        post = value.documents;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
          : post.isEmpty
              ? Center(
                  child: Text('You have not posted any requests yet!'),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(top: 40),
                  itemCount: post.length,
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  post[index]['name'],
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                post[index]['dateTime'],
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: post[index]['image'] == 'none'
                                ? Image.asset('assets/placeholder.png')
                                : FadeInImage(
                                    placeholder:
                                        AssetImage('assets/placeholder.png'),
                                    image: NetworkImage(
                                      post[index]['image'],
                                    ),
                                    fit: BoxFit.fill,
                                  )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.message,
                              size: 40.0,
                              color: Colors.grey,
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(
                                  post[index]['description'],
                                  softWrap: true,
                                  style: GoogleFonts.quicksand(
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              size: 45.0,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                post[index]['location'],
                                softWrap: true,
                                style: GoogleFonts.quicksand(
                                  textStyle:
                                      TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? MediaQuery.of(context).size.width * 0.026
                                    : MediaQuery.of(context).size.width * 0.09,
                              ),
                              CircleAvatar(
                                child: Text(
                                  post[index]['reacted'].length.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.grey,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                              ),
                              Text(
                                ' persons reacted',
                                style: GoogleFonts.openSans(
                                  textStyle:
                                      TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        SizedBox(
                          width: 300,
                          child: RaisedButton(
                            color: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Are you Sure?'),
                                  content: Text(
                                      'Are you sure you want to delete this request permanently?'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        Provider.of<PostProvider>(context,
                                                listen: false)
                                            .deletePost(post[index].documentID)
                                            .then((value) {
                                          if (value) {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: ctx,
                                              builder: (ctx1) => AlertDialog(
                                                title: Text(
                                                    "Request deleted Successfully!"),
                                                content: Text(
                                                    'Your request post has been successfully deleted , please follow this practise after your request is fulfilled.'),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(ctx1).pop();
                                                      Navigator.of(ctx).pop();
                                                      isInit = true;
                                                      didChangeDependencies();
                                                    },
                                                    child: Text('Okay'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            showDialog(
                                              context: ctx,
                                              builder: (ctx1) => AlertDialog(
                                                title: Text(
                                                    "Could not delete request post!"),
                                                content: Text(
                                                    'Something went wrong, please check your internet connection or try again later.'),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(ctx1).pop();
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
                                      child: Text('Okay'),
                                    )
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              'Delete Post',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ),
    );
  }
}
