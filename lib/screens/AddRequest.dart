import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/post.dart';
import '../providers/user.dart';

class AddRequest extends StatefulWidget {
  static const routeName = '/AddRequest';
  @override
  _AddRequestState createState() => _AddRequestState();
}

class _AddRequestState extends State<AddRequest> {
  final _form = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _location = TextEditingController();
  bool isSwitched = false;
  bool isLoading = false;
  final picker = ImagePicker();
  File _file;
  Post _postDetails = Post(
    userId: '',
    type: '',
    district: '',
    dateTime: '',
    description: '',
    familyMembers: '',
    image: null,
    location: '',
    reacted: [],
    name: '',
  );
  DateTime date;
  final List<String> type = [
    'All Departments',
    'Police',
    'District Administration',
    'KSEB',
    'Kerala Water Authority',
    'Fire and Rescue',
    'Evacuation Team',
    'Volunteer',
    'PWD',
    'Others',
  ];
  var _selectedType;
  final GlobalKey<FormState> _formKey = GlobalKey();

  void save() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      final userDetails =
          Provider.of<UserProvider>(context, listen: false).user;
      final dateTime =
          '${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jms().format(DateTime.now())}';
      _postDetails = Post(
        dateTime: dateTime,
        description: _postDetails.description,
        userId: userDetails.userId,
        district: userDetails.district,
        familyMembers: userDetails.family,
        image: _file,
        location: _postDetails.location,
        reacted: [],
        type: _postDetails.type,
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
                  'Your request has been submitted successfully, please delete the request after your need is fulfilled.'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
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
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  void autofill(bool value) async {
    setState(() {
      isLoading = true;
      isSwitched = value;
    });
    if (isSwitched == true) {
      final geolocator = Geolocator();
      Position position = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: 'en');
      setState(() {
        placemark.forEach((element) {
          _location.text =
              '${element.name}  ${element.thoroughfare}  ${element.subLocality}-${element.postalCode}  ${element.locality}  ${element.administrativeArea}  ${element.country}';

          isLoading = false;
        });
      });
    } else {
      setState(() {
        _location.text = "";

        isLoading = false;
      });
    }
  }

  void setImage(bool isGallery) {
    picker
        .getImage(source: isGallery ? ImageSource.gallery : ImageSource.camera)
        .then((value) {
      if (value != null && value.path != null) {
        setState(() {
          _file = File(value.path);
        });
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Helping Hands',
          style: GoogleFonts.doHyeon(
            fontSize: 30,
            letterSpacing: 2,
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(1),
                child: Form(
                  key: _form,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Auto Location',
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.blue[900],
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Switch(
                                  value: isSwitched,
                                  onChanged: (value) => autofill(value),
                                  activeTrackColor: Colors.blue[800],
                                  activeColor: Colors.blue[900],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(
                                icon: Icon(Icons.location_on),
                                labelText: 'Enter Location',
                              ),
                              keyboardType: TextInputType.text,
                              controller: _location,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please provide a location or place';
                                }
                                return null;
                              },
                              onSaved: (location) {
                                _postDetails = Post(
                                  location: location,
                                  dateTime: _postDetails.dateTime,
                                  description: _postDetails.description,
                                  district: _postDetails.district,
                                  familyMembers: _postDetails.familyMembers,
                                  image: _postDetails.image,
                                  reacted: _postDetails.reacted,
                                  type: _postDetails.type,
                                  userId: _postDetails.userId,
                                  name: _postDetails.name,
                                );
                              },
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.012,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.012),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.all(8),
                              width: MediaQuery.of(context).size.width * 0.55,
                              height: MediaQuery.of(context).size.height * 0.09,
                              child: DropdownButton(
                                dropdownColor: Colors.blue[800],
                                items: type.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: Text(
                                  'Select Request Type',
                                  textAlign: TextAlign.center,
                                ),
                                value: _selectedType,
                                elevation: 10,
                                onChanged: (newValue) {
                                  _postDetails = Post(
                                    location: _postDetails.location,
                                    dateTime: _postDetails.dateTime,
                                    description: _postDetails.description,
                                    district: _postDetails.district,
                                    familyMembers: _postDetails.familyMembers,
                                    image: _postDetails.image,
                                    reacted: _postDetails.reacted,
                                    type: newValue,
                                    userId: _postDetails.userId,
                                    name: _postDetails.name,
                                  );
                                  setState(
                                    () {
                                      _selectedType = newValue;
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.012),
                            TextFormField(
                              decoration: InputDecoration(
                                icon: Icon(Icons.description),
                                labelText: 'Description',
                              ),
                              controller: _description,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: 6,
                              onSaved: (value) {
                                _postDetails = Post(
                                  location: _postDetails.location,
                                  dateTime: _postDetails.dateTime,
                                  description: value,
                                  district: _postDetails.district,
                                  familyMembers: _postDetails.familyMembers,
                                  image: _postDetails.image,
                                  reacted: _postDetails.reacted,
                                  type: _postDetails.type,
                                  userId: _postDetails.userId,
                                  name: _postDetails.name,
                                );
                              },
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Row(
                              children: <Widget>[
                                InkWell(
                                  splashColor: Colors.blue[800],
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Select your Image source'),
                                      content: Text(
                                          'Please select the source of the image.'),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () {
                                            setImage(true);
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Text('Gallery'),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            setImage(false);
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Text('Camera'),
                                        )
                                      ],
                                    ),
                                  ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.890,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: _file == null
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'Add Image(optional)',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.add,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                              ],
                                            ),
                                          )
                                        : Image(
                                            image: FileImage(_file),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.012,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.89,
                        child: RaisedButton(
                          color: Colors.blue[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: save,
                          child: Text(
                            'Post',
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }
}
