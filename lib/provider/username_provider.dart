import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';

final usernameProvider =
    FutureProvider.family<String, String>((ref, userID) async {
  final username = await FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .get()
      .then((userData) => userData.get('username'));
  return username;
});
