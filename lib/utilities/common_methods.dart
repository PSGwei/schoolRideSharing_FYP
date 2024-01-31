import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

checkConnectivity(BuildContext context) async {
  var connectionResult = await Connectivity().checkConnectivity();
  if (connectionResult != ConnectivityResult.mobile &&
      connectionResult != ConnectivityResult.wifi) {
    if (!context.mounted) {
      return;
    }
    displaySnackbar('Internet connnection is not available', context);
  }
}

void displaySnackbar(String message, BuildContext context) {
  var snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

  // static storeUserData(Map<String, dynamic> data, String uid) async {
  //   await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //     'username': data['username'],
  //     'email': data['email'],
  //   });
  // }

  // static User? getCurrentUser() {
  //   return FirebaseAuth.instance.currentUser;
  // }

