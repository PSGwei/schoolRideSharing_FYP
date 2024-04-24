import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:school_ride_sharing/models/user.dart' as models;
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';
import 'package:school_ride_sharing/utilities/storage_method.dart';

class AuthMethods {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String result = "Something went wrong";

  // Sign Up
  Future<String> signUp({
    required String email,
    required String password,
    required String username,
    required String gender,
    required String imagePath,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final Uint8List imageBytes = await loadProjectImageBytes(imagePath);

      String imageURL =
          await StorageMethods().uploadImageToStorage('avatars', imageBytes);

      models.User user = models.User(
        uid: userCredential.user!.uid,
        username: username,
        gender: gender,
        avatar: imageURL,
        // credit: credit,
      );

      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .set(user.toJson());
      result = 'Success';
    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        result = 'Error: Password length should more than 5 characters';
      } else if (error.code == 'email-already-in-use') {
        result = 'Error: The account already exists for that email.';
      }
    } catch (error) {
      result = error.toString();
    }

    return result;
  }

  // Log In
  Future<String> loginUser(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      result = 'success';
    } catch (error) {
      result = error.toString();
    }
    return result;
  }

  // Sign in with Google
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) return result;

    // obtain auth details
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // create credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    final Uint8List imageBytes =
        await loadProjectImageBytes(gUser.photoUrl ?? defaultAvatar);

    String imageURL =
        await StorageMethods().uploadImageToStorage('avatars', imageBytes);

    models.User user = models.User(
      uid: firebaseAuth.currentUser!.uid,
      username: gUser.displayName ?? 'User',
      gender: "",
      avatar: imageURL,
    );

    await firestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .set(user.toJson());

    return result = "Success";
  }

  // Get user information
  Future<models.User> getUserDetails([String? uid]) async {
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid ?? FirebaseAuth.instance.currentUser!.uid)
        .get();
    return models.User.toUserModel(user);
  }

  Future<List<models.User>> getUserDetails2(List<String> uids) async {
    List<models.User> usersDetails = [];
    for (String uid in uids) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      models.User user = models.User.toUserModel(userSnapshot);
      usersDetails.add(user);
    }
    return usersDetails;
  }
}
