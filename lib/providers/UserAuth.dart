import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './user.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class AuthExceptionHandler {
  static handleException(e) {
    print(e.code);
    var status;
    switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        status = AuthResultStatus.invalidEmail;
        break;
      case "ERROR_WRONG_PASSWORD":
        status = AuthResultStatus.wrongPassword;
        break;
      case "ERROR_USER_NOT_FOUND":
        status = AuthResultStatus.userNotFound;
        break;
      case "ERROR_USER_DISABLED":
        status = AuthResultStatus.userDisabled;
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        status = AuthResultStatus.tooManyRequests;
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      default:
        status = AuthResultStatus.undefined;
    }
    return status;
  }

  ///
  /// Accepts AuthExceptionHandler.errorType
  ///
  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage =
            "Your email address is invalid. Please enter a valid mail id.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage =
            "Your password is incorrect. Please enter correct password.";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "User with this email doesn't exist.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage =
            "User with this email has been disabled. Please contact authorities";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Too many requests. Try again later.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage =
            "Signing in with Email and Password is not enabled. Please contact authorities.";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage =
            "The email has already been registered. Please login or reset your password.";
        break;
      default:
        errorMessage =
            "An undefined Error occured. Please check your internet connection and try again later.";
    }

    return errorMessage;
  }
}

class UserAuth with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  FirebaseUser get user {
    return _user;
  }

  Future<FirebaseUser> getUser() async {
    _auth.currentUser().then((value) {
      if (value != null) {
        _user = value;
      }
    });
    notifyListeners();
    return _user;
  }

  Future<AuthResultStatus> signUpUser(User userDetails, String password) async {
    AuthResultStatus _status;
    try {
      final cloud = Firestore.instance;
      final result = await _auth.createUserWithEmailAndPassword(
          email: userDetails.email, password: password);
      if (result.user != null) {
        _status = AuthResultStatus.successful;
      } else {
        _status = AuthResultStatus.undefined;
      }
      cloud.collection('user').add({
        'name': userDetails.name,
        'gender': userDetails.gender,
        'email': userDetails.email,
        'district': userDetails.district,
        'address': userDetails.address,
        'family': userDetails.family,
        'phone number': userDetails.phnumber,
        'type': userDetails.type,
      });
    } catch (e) {
      _status = AuthExceptionHandler.handleException(e);
    }
    notifyListeners();
    return _status;
  }

  Future<AuthResultStatus> signInUser(
      String email, String password, bool autoLogin) async {
    AuthResultStatus _status;
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        if (!autoLogin) {
          FlutterSecureStorage().write(key: 'email', value: email);
          FlutterSecureStorage().write(key: 'password', value: password);
        }
        _status = AuthResultStatus.successful;
        _user = result.user;
      } else {
        _status = AuthResultStatus.undefined;
      }
    } catch (e) {
      _status = AuthExceptionHandler.handleException(e);
    }
    notifyListeners();
    return _status;
  }

  Future<AuthResultStatus> resetPassword(String email) async {
    AuthResultStatus _status = AuthResultStatus.successful;
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _status = AuthExceptionHandler.handleException(e);
    }
    notifyListeners();
    return _status;
  }

  void logOUt() {
    _auth.signOut().then(
      (value) {
        FlutterSecureStorage().delete(key: 'email');
        FlutterSecureStorage().delete(key: 'password');
        _user = null;
      },
    );
    notifyListeners();
  }
}
