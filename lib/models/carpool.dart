import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_ride_sharing/models/user.dart';

class Carpool {
  Carpool({
    required this.id,
    required this.user,
    required this.pickUp,
    required this.destination,
    required this.totalSeat,
    required this.availableSeat,
    required this.departureTime,
    required this.participants,
  });

  final String id;
  final User user;
  final String pickUp;
  final String destination;
  final int totalSeat;
  final int availableSeat;
  final DateTime departureTime;
  // final List<User> participants;
  final List<String> participants;

  String get date {
    return DateFormat.yMd().format(departureTime);
  }

  String get time {
    return DateFormat.jm().format(departureTime);
  }

  //create a CarpoolRequest object from Firestore data
  factory Carpool.fromFireStore(Map<String, dynamic> data) {
    // List<Map<String, dynamic>> participantsData = data['participants'];

    // convert array to List<String>
    List<String> participants = List<String>.from(data['participants']);

    // List<User> participants = participantsData
    //     .map((participant) => User.fromMap(participant))
    //     .toList();

    Timestamp timestamp = data['departure_time'];

    return Carpool(
      id: data['id'],
      user: User.fromMap(data['user']),
      pickUp: data['from'],
      destination: data['to'],
      totalSeat: data['total_seat'],
      availableSeat: data['available_seat'],
      departureTime: timestamp.toDate(),
      // participants: participants,
      participants: participants,
    );
  }

  static void addCarpool(Carpool carpool) async {
    await FirebaseFirestore.instance.collection('carpools').add({
      'id': carpool.id,
      'from': carpool.pickUp,
      'to': carpool.destination,
      'total_seat': carpool.totalSeat,
      'available_seat': carpool.availableSeat,
      'departure_time': carpool.departureTime,
      'user': {
        'uid': carpool.user.uid,
        'username': carpool.user.userName,
        'credit': carpool.user.credit,
        'gender': carpool.user.gender,
        'avatar': carpool.user.avatar,
      },
      // 'participants': [participantsData],
      'participants': [],
    });
  }
}
