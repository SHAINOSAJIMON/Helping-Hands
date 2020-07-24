import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String name;

  final String userId;
  final String phNumber;
  final String dateTime;
  final File image;
  final String description;
  final String location;
  final List<String> reacted;
  final String type;
  final String district;
  final String familyMembers;

  Post({
    this.phNumber,
    this.name,
    this.userId,
    this.district,
    this.type,
    this.dateTime,
    this.description,
    this.image,
    this.location,
    this.reacted,
    this.familyMembers,
  });
}

class PostProvider with ChangeNotifier {
  static final cloud = Firestore.instance;

  Stream<QuerySnapshot> _query = cloud
      .collection('post')
      .orderBy('dateTime', descending: true)
      .snapshots();
  Stream<QuerySnapshot> get query {
    return _query;
  }

  void getPost(String type) {
    _query = cloud
        .collection('post')
        .orderBy('dateTime', descending: true)
        .where('type', isEqualTo: type)
        .snapshots();
    notifyListeners();
  }

  void getAllPost() {
    _query = cloud
        .collection('post')
        .orderBy('dateTime', descending: true)
        .snapshots();
    notifyListeners();
  }

  Future<bool> addPost(Post post) async {
    var _imageUpload;
    var _downloadUrl;

    try {
      if (post.image != null) {
        StorageUploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('post/${Path.basename(post.image.path)}')
            .putFile(post.image);
        StorageTaskSnapshot storagesnapshot = await uploadTask.onComplete;
        _downloadUrl = await storagesnapshot.ref.getDownloadURL();
        _imageUpload = uploadTask.isComplete;
      } else if (post.image == null && post.type == 'SOS') {
        _downloadUrl = 'sos';
        _imageUpload = true;
      } else {
        _downloadUrl = 'none';
        _imageUpload = true;
      }

      if (_imageUpload) {
        final result = await cloud.collection('post').add({
          'userId': post.userId,
          'district': post.district,
          'type': post.type,
          'dateTime': post.dateTime,
          'description': post.description,
          'image': _downloadUrl.toString(),
          'location': post.location,
          'reacted': post.reacted,
          'familyMember': post.familyMembers,
          'name': post.name,
          'phNumber': post.phNumber,
        });
        if (result.documentID == null) {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<QuerySnapshot> getUserPost(String userId) async {
    try {
      final result = await cloud
          .collection('post')
          .where('userId', isEqualTo: userId)
          .orderBy('dateTime', descending: true)
          .getDocuments();
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      cloud.collection('post').document(postId).delete().then((value) {
        return true;
      });
    } catch (e) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<String> react(String postId, String userId) async {
    try {
      final post = await cloud.collection('post').document(postId).get();
      List<dynamic> reacted = post['reacted'];
      final check = reacted.contains(userId);
      if (check) {
        return 'already there';
      } else {
        reacted.add(userId);
      }
      await cloud
          .collection('post')
          .document(postId)
          .updateData({'reacted': reacted}).then((value) {
        return 'success';
      });
    } catch (e) {
      print(e);
      return 'error';
    }
    notifyListeners();
    return 'success';
  }
}
