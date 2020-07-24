import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String name;
  final String gender;
  final String email;
  final String type;
  final String district;
  final String address;
  final String phnumber;
  final String family;

  User(
      {this.userId,
      this.name,
      this.email,
      this.address,
      this.district,
      this.family,
      this.gender,
      this.phnumber,
      this.type});
}

class UserProvider with ChangeNotifier {
  User _user;
  User get user {
    return _user;
  }

  Future<void> getUserDetails(String email) async {
    final cloud = Firestore.instance;
    await cloud
        .collection('user')
        .where('email', isEqualTo: email)
        .getDocuments()
        .then((value) {
      for (DocumentSnapshot userDetails in value.documents) {
        _user = User(
          address: userDetails['address'],
          district: userDetails['district'],
          email: userDetails['email'],
          family: userDetails['family'],
          gender: userDetails['gender'],
          name: userDetails['name'],
          phnumber: userDetails['phone number'],
          type: userDetails['type'],
          userId: userDetails.documentID,
        );
      }
    });
    notifyListeners();
  }
}
