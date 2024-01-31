import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  const User({
    required this.uid,
    required this.username,
    required this.avatar,
    required this.gender,
    this.credit = 0,
  });

  final String uid;
  final String username;
  final String avatar;
  final String gender;
  final int credit;

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "avatar": avatar,
        "gender": gender,
        "credit": credit,
      };

  // convert map data to model
  static User toUserModel(DocumentSnapshot snapshot) {
    return User(
      uid: snapshot['uid'],
      username: snapshot['username'],
      avatar: snapshot['avatar'],
      gender: snapshot['gender'],
      credit: snapshot['credit'],
    );
  }
}
