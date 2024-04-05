import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_ride_sharing/models/address.dart';

class User {
  const User({
    required this.uid,
    required this.username,
    required this.avatar,
    required this.gender,
    this.defaultAddress,
    this.credit = 0,
  });

  final String uid;
  final String username;
  final String avatar;
  final String gender;
  final Address? defaultAddress;
  final int credit;

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "avatar": avatar,
        "gender": gender,
        "credit": credit,
        "default_address":
            defaultAddress?.toJson() ?? Address.emptyAddress().toJson(),
      };

  // convert map data to model
  static User toUserModel(DocumentSnapshot snapshot) {
    return User(
      uid: snapshot['uid'],
      username: snapshot['username'],
      avatar: snapshot['avatar'],
      gender: snapshot['gender'],
      defaultAddress: (snapshot['default_address'] as Map).isNotEmpty
          ? Address.toAddressModel(snapshot['default_address'])
          : null,
      credit: snapshot['credit'],
    );
  }
}
