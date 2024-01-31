import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Carpool {
  Carpool({
    required this.id,
    required this.uid,
    required this.pickUp,
    required this.destination,
    required this.totalSeat,
    required this.availableSeat,
    required this.departureTime,
    required this.participants,
  });

  final String id;
  final String uid;
  final String pickUp;
  final String destination;
  final int totalSeat;
  final int availableSeat;
  final DateTime departureTime;
  final List<String> participants;

  String get date {
    return DateFormat.yMd().format(departureTime);
  }

  String get time {
    return DateFormat.jm().format(departureTime);
  }

  static Carpool toCarpoolModel(Map<String, dynamic> snapshot) {
    Timestamp timestamp = snapshot['departure_time'];

    // convert array to List<String>
    List<String> participants = List<String>.from(snapshot['participants']);

    return Carpool(
      id: snapshot['id'],
      uid: snapshot['uid'],
      pickUp: snapshot['from'],
      destination: snapshot['to'],
      totalSeat: snapshot['total_seat'],
      availableSeat: snapshot['available_seat'],
      departureTime: timestamp.toDate(),
      participants: participants,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "pickUp": pickUp,
        "destination": destination,
        "totalSeat": totalSeat,
        "availableSeat": availableSeat,
        "departureTime": departureTime,
        "participants": participants,
      };
}
