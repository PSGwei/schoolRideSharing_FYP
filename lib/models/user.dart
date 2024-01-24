import 'dart:io';

class User {
  const User({
    required this.uid,
    required this.userName,
    required this.avatar,
    required this.gender,
    required this.credit,
  });

  final String uid;
  final String userName;
  final File? avatar;
  final String gender;
  final int credit;

  // convert map data to model
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      userName: map['username'],
      avatar: null,
      gender: map['gender'],
      credit: map['credit'],
    );
  }
}
