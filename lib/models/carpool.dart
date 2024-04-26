import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_ride_sharing/models/address.dart';

class Carpool {
  Carpool({
    required this.id,
    required this.uid,
    required this.pickUp,
    required this.destination,
    this.distance = 0.0,
    required this.totalSeat,
    required this.availableSeat,
    required this.departureTime,
    required this.participants,
    required this.status,
    this.imageURL = '',
  });

  final String id;
  final String uid;
  final Address pickUp;
  final Address destination;
  double distance;
  final int totalSeat;
  final int availableSeat;
  final DateTime departureTime;
  final List<String> participants;
  final bool status;
  final String imageURL;

  String get date {
    return DateFormat.yMd().format(departureTime);
  }

  String get time {
    return DateFormat.jm().format(departureTime);
  }

  static Carpool toCarpoolModel(Map<String, dynamic> snapshot) {
    Timestamp timestamp = snapshot['departureTime'];

    // convert array to List<String>
    List<String> participants = List<String>.from(snapshot['participants']);

    return Carpool(
      id: snapshot['id'],
      uid: snapshot['uid'],
      pickUp: Address.toAddressModel(snapshot['pickUp']),
      destination: Address.toAddressModel(snapshot['destination']),
      // distance: snapshot['distance'],
      totalSeat: snapshot['totalSeat'],
      availableSeat: snapshot['availableSeat'],
      departureTime: timestamp.toDate(),
      participants: participants,
      status: snapshot['status'],
      imageURL: snapshot['evidence'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "pickUp": pickUp.toJson(),
        "destination": destination.toJson(),
        "totalSeat": totalSeat,
        "availableSeat": availableSeat,
        "departureTime": departureTime,
        "participants": participants,
        'status': status,
        'evidence': imageURL,
      };
}
