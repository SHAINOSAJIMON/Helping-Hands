import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../providers/UserAuth.dart';
import './SignUp.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final nameController = TextEditingController();
  final _resetPassword = TextEditingController();
  final _passwordController = TextEditingController();
  var isLoading = true;
  var isInit = true;

  // @override
  // void didChangeDependencies() {
  //   if (isInit) {
  //     isInit = false;

  //   }
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    FlutterSecureStorage().read(key: 'email').then((email) {
      if (email != null) {
        FlutterSecureStorage().read(key: 'password').then((password) {
          if (password != null) {
            autoLogin(email, password);
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    _passwordController.dispose();
    _resetPassword.dispose();
    super.dispose();
  }

  void autoLogin(String email, String password) async {
    setState(() {
      isLoading = true;
    });
    Provider.of<UserAuth>(context, listen: false)
        .signInUser(email, password, true)
        .then((value) {
      if (value != AuthResultStatus.successful) {
        setState(
          () {
            isLoading = false;
          },
        );
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
      }
    });
  }

  void login(String email, String password) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      Provider.of<UserAuth>(context, listen: false)
          .signInUser(email.trim(), password, false)
          .then((value) {
        if (value != AuthResultStatus.successful) {
          setState(
            () {
              isLoading = false;
            },
          );
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
        }
      });
    } else {
      return null;
    }
  }

  void resetPassword() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Password'),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          child: Column(
            children: <Widget>[
              Text(
                  'Please enter the e-mail id you have registered with. A password reset link would be sent to this e-mail id'),
              TextField(
                decoration: InputDecoration(labelText: "Enter e-mail id"),
                controller: _resetPassword,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          FlatButton(
              onPressed: () {
                if (_resetPassword.text.isEmpty) {
                  showDialog(
                    context: ctx,
                    builder: (ctx1) => AlertDialog(
                      title: Text('An Error Occured'),
                      content: Text('Please enter an email id'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx1).pop();
                          },
                          child: Text('Okay'),
                        ),
                      ],
                    ),
                  );
                }
                if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(_resetPassword.text)) {
                  showDialog(
                    context: ctx,
                    builder: (ctx1) => AlertDialog(
                      title: Text('An Error Occured'),
                      content: Text('Please enter a valid email id'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx1).pop();
                          },
                          child: Text('Okay'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Provider.of<UserAuth>(context, listen: false)
                      .resetPassword(_resetPassword.text)
                      .then(
                    (value) {
                      if (value != AuthResultStatus.successful) {
                        showDialog(
                          context: ctx,
                          builder: (ctx1) => AlertDialog(
                            title: Text('An Error Occured'),
                            content: Text(
                              AuthExceptionHandler.generateExceptionMessage(
                                  value),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(ctx1).pop();
                                },
                                child: Text('Okay'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        showDialog(
                          barrierDismissible: true,
                          context: ctx,
                          builder: (ctx1) => AlertDialog(
                            title: Text('E-mail sent succesfully'),
                            content: Text(
                                'Password reset e-mail have been sent succefully'),
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
                    },
                  );
                }
              },
              child: Text('Send E-mail'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Helping Hands',
          textAlign: TextAlign.center,
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
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        height: 75,
                        child: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 20, right: 10, top: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelText: 'Email',
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
                        ),
                      ),
                      Container(
                        height: 75,
                        child: TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 20, right: 10, top: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelText: 'Password',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                              width: MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? MediaQuery.of(context).size.width * 0.75
                                  : MediaQuery.of(context).size.width * 0.51),
                          FlatButton(
                            onPressed: resetPassword,
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.quicksand(),
                            ),
                            textColor: Colors.blue[800],
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Container(
                        height: 50,
                        child: RaisedButton(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          textColor: Colors.white,
                          color: Colors.blue[900],
                          child: Text(
                            'Login',
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(fontSize: 20),
                            ),
                          ),
                          onPressed: () => login(
                              nameController.text, _passwordController.text),
                        ),
                      ),
                      Container(
                          child: FlatButton(
                        textColor: Colors.blue[700],
                        child: Text(
                          'Haven\'t registered yet? Click here.',
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(fontSize: 15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(SignUp.routeName);
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
