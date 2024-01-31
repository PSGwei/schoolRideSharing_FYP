import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:school_ride_sharing/provider/username_provider.dart';
import 'package:school_ride_sharing/screens/authentication.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final username = ref.watch(usernameProvider(user!.uid));
    // final user = FirebaseAuth.instance.currentUser;
    // if (user == null) {
    //   // CommonMethods.displaySnackbar(
    //   //     'Something went wrong. Please try again later', context);
    // }
    void logOut() async {
      checkConnectivity(context);
      await FirebaseAuth.instance.signOut();
      // force the provider to re-evaluate its future and fetch the new username
      //ref.refresh(usernameProvider(user.uid));
      for (UserInfo profile in user.providerData) {
        // Sign in with Google?
        // reset user's Google status
        if (profile.providerId == GoogleAuthProvider.PROVIDER_ID) {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          await googleSignIn.signOut();
          await googleSignIn.disconnect(); //Clear the cached sign-in
        }
      }
      // FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      //   if (user != null) {
      //     var userDoc = await FirebaseFirestore.instance
      //         .collection('users')
      //         .doc(user.uid)
      //         .get();
      //     if (!userDoc.exists) {
      //       for (UserInfo profile in user.providerData) {
      //         // Sign in with Google?
      //         // reset user's Google status
      //         if (profile.providerId == GoogleAuthProvider.PROVIDER_ID) {
      //           final GoogleSignIn googleSignIn = GoogleSignIn();
      //           await googleSignIn.signOut();
      //           await googleSignIn.disconnect();  //Clear the cached sign-in
      //         }
      //       }
      //     }
      //   }
      // });

      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()));
    }

    return Column(
      children: [
        username.when(
          data: (username) => Text(username),
          loading: () => const SizedBox(), // show nothing when loading
          error: (e, st) => const Text('username display error'),
        ),
        Text(user.uid),
        ElevatedButton(onPressed: logOut, child: const Text('Log out')),
      ],
    );
  }
}
