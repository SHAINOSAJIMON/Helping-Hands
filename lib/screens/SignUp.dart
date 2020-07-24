import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/UserAuth.dart';
import '../providers/user.dart';

class SignUp extends StatefulWidget {
  static const routeName = '/signup';
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var _groupValue;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _password = TextEditingController();
  var isLoading = false;
  final List<String> districts = [
    'Thiruvananthapuram',
    'Kollam',
    'Alappuzha',
    'Pathanamthitta',
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Thrissur',
    'Palakkad',
    'Malappuram',
    'Kozhikode',
    'Wayanad',
    'Kannur',
    'Kasaragod',
  ];
  var _selectedDistrict;
  final List<String> type = [
    'General User',
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

  User userDetails = User(
      address: '',
      district: '',
      gender: '',
      phnumber: '',
      type: '',
      family: '',
      email: '',
      name: '');

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void save() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      Provider.of<UserAuth>(context, listen: false)
          .signUpUser(userDetails, _password.text)
          .then((value) {
        setState(() {
          isLoading = false;
        });
        if (value != AuthResultStatus.successful) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('An Error Occured!'),
              content: Text(
                AuthExceptionHandler.generateExceptionMessage(value),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Okay'))
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Registration successful'),
              content: Text('The user is added successfully'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text('Okay'))
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
          : Container(
              padding: EdgeInsets.all(13),
              margin: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          hintText: 'Enter your full name',
                          labelText: 'Name',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (value.contains(RegExp(r'[0-9]'))) {
                            return 'Enter alphabets only';
                          }
                          return null;
                        },
                        onSaved: (input) {
                          userDetails = User(
                              address: userDetails.address,
                              district: userDetails.district,
                              gender: userDetails.gender,
                              phnumber: userDetails.phnumber,
                              type: userDetails.type,
                              family: userDetails.family,
                              email: userDetails.email,
                              name: input);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          hintText: 'Enter your email',
                          labelText: 'E-mail',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an email id';
                          }
                          if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                            return 'Enter a valid mail id';
                          }
                          return null;
                        },
                        onSaved: (input) {
                          userDetails = User(
                              address: userDetails.address,
                              district: userDetails.district,
                              gender: userDetails.gender,
                              phnumber: userDetails.phnumber,
                              type: userDetails.type,
                              family: userDetails.family,
                              email: input,
                              name: userDetails.name);
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.012,
                      ),
                      Text(
                        'Gender',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20),
                      ),
                      Center(
                        child: RadioListTile(
                          title: Text('Male'),
                          value: 'Male',
                          groupValue: _groupValue,
                          onChanged: (newValue) {
                            setState(() {
                              _groupValue = newValue;
                            });

                            userDetails = User(
                                address: userDetails.address,
                                district: userDetails.district,
                                gender: newValue,
                                phnumber: userDetails.phnumber,
                                type: userDetails.type,
                                family: userDetails.family,
                                email: userDetails.email,
                                name: userDetails.name);
                          },
                        ),
                      ),
                      RadioListTile(
                        title: Text('Female'),
                        value: 'Female',
                        groupValue: _groupValue,
                        onChanged: (newValue) {
                          setState(() {
                            _groupValue = newValue;
                          });

                          userDetails = User(
                              address: userDetails.address,
                              district: userDetails.district,
                              gender: newValue,
                              phnumber: userDetails.phnumber,
                              type: userDetails.type,
                              family: userDetails.family,
                              email: userDetails.email,
                              name: userDetails.name);
                        },
                      ),
                      RadioListTile(
                        title: Text('Other'),
                        value: 'Other',
                        groupValue: _groupValue,
                        onChanged: (newValue) {
                          setState(() {
                            _groupValue = newValue;
                          });

                          userDetails = User(
                              address: userDetails.address,
                              district: userDetails.district,
                              gender: newValue,
                              phnumber: userDetails.phnumber,
                              type: userDetails.type,
                              family: userDetails.family,
                              email: userDetails.email,
                              name: userDetails.name);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            DropdownButton(
                              dropdownColor: Colors.blue[800],
                              items: districts.map((String value) {
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
                              hint: Text('Select your District'),
                              value: _selectedDistrict,
                              elevation: 10,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedDistrict = newValue;
                                });

                                userDetails = User(
                                    address: userDetails.address,
                                    district: newValue,
                                    gender: userDetails.gender,
                                    phnumber: userDetails.phnumber,
                                    type: userDetails.type,
                                    family: userDetails.family,
                                    email: userDetails.email,
                                    name: userDetails.name);
                              },
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.012,
                            ),
                            DropdownButton(
                              dropdownColor: Colors.blue[800],
                              items: type.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              hint: Text('Select User Type'),
                              value: _selectedType,
                              elevation: 10,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedType = newValue;
                                });

                                userDetails = User(
                                    address: userDetails.address,
                                    district: userDetails.district,
                                    gender: userDetails.gender,
                                    phnumber: userDetails.phnumber,
                                    type: newValue,
                                    family: userDetails.family,
                                    email: userDetails.email,
                                    name: userDetails.name);
                              },
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          icon: Icon(Icons.contacts),
                          hintText: 'Enter your phone number',
                          labelText: 'Phone Number',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (value.length != 10) {
                            return 'Enter a ten digit number';
                          }
                          if (value.contains(RegExp(r'[a-z]')) ||
                              value.contains(RegExp(r'[A-Z]'))) {
                            return 'Phone number should only be numbers';
                          }
                          return null;
                        },
                        onSaved: (input) {
                          userDetails = User(
                              address: userDetails.address,
                              district: userDetails.district,
                              gender: userDetails.gender,
                              phnumber: input,
                              type: userDetails.type,
                              family: userDetails.family,
                              email: userDetails.email,
                              name: userDetails.name);
                        },
                      ),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock),
                          hintText: 'Enter your password',
                          labelText: 'Password',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Must be more than 6 characters';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Password must have at least one number';
                          }
                          if (!value.contains(RegExp(r'[a-z]'))) {
                            return 'Password must have  at least one alphabet in lower case';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Password must have at least one alphabet in uppercase';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock),
                          hintText: 'Enter your password',
                          labelText: 'Confirm Password',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value != _password.text) {
                            return 'Enter same password';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        decoration: InputDecoration(
                          icon: Icon(Icons.my_location),
                          hintText: 'Enter your address',
                          labelText: 'Address',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                        onSaved: (input) {
                          userDetails = User(
                              address: input,
                              district: userDetails.district,
                              gender: userDetails.gender,
                              phnumber: userDetails.phnumber,
                              type: userDetails.type,
                              family: userDetails.family,
                              email: userDetails.email,
                              name: userDetails.name);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          icon: Icon(Icons.group),
                          hintText: 'Enter number of family members',
                          labelText: 'Number of family members',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter number of family members';
                          }
                          if (value.contains(RegExp(r'[a-z]')) ||
                              value.contains(RegExp(r'[A-Z]'))) {
                            return 'Phone number should only be numbers';
                          }
                          return null;
                        },
                        onSaved: (input) {
                          userDetails = User(
                              address: userDetails.address,
                              district: userDetails.district,
                              gender: userDetails.gender,
                              phnumber: userDetails.phnumber,
                              type: userDetails.type,
                              family: input,
                              email: userDetails.email,
                              name: userDetails.name);
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.012,
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.89,
                          child: RaisedButton(
                            color: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onPressed: save,
                            child: Text(
                              'Submit',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
