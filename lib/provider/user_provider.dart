import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/models/user.dart';
import 'package:school_ride_sharing/utilities/authentication_method.dart';

final userProvider = FutureProvider.family<User, String>(
  (ref, uid) async => await AuthMethods().getUserDetails(uid),
);
