import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:school_ride_sharing/models/user.dart' as user;
import 'package:school_ride_sharing/utilities/authentication_method.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final currentUserID = firebaseAuth.currentUser!.uid;

class UserCurrentLocationNotifier extends StateNotifier<Position?> {
  UserCurrentLocationNotifier() : super(null);

  void updateCurrentLocation(Position position) {
    state = position;
  }
}

final currentLocationProvider =
    StateNotifierProvider<UserCurrentLocationNotifier, Position?>(
  (ref) => UserCurrentLocationNotifier(),
);

final currentUserProvider = FutureProvider<user.User>(
  (ref) async => await AuthMethods().getUserDetails(currentUserID),
);
