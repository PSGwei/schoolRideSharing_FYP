import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

final userIdProvider = StreamProvider<String?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) => user!.uid);
});
