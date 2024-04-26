import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:school_ride_sharing/provider/user_provider.dart';
import 'package:school_ride_sharing/screens/authentication.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue =
        ref.watch(userProvider(FirebaseAuth.instance.currentUser!.uid));

    void logOut() async {
      checkConnectivity(context);
      await FirebaseAuth.instance.signOut();
      // force the provider to re-evaluate its future and fetch the new username
      //ref.refresh(usernameProvider(user.uid));
      for (UserInfo profile
          in FirebaseAuth.instance.currentUser!.providerData) {
        // Sign in with Google?
        // reset user's Google status
        if (profile.providerId == GoogleAuthProvider.PROVIDER_ID) {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          await googleSignIn.signOut();
          await googleSignIn.disconnect(); //Clear the cached sign-in
        }
      }

      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()));
    }

    return userAsyncValue.when(
      data: (user) {
        // This is where you build your UI with the user data
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(user.avatar),
              ),
              Text(
                "Welcome, ${user.username}",
                style: TextStyle(fontSize: 17),
              ),
              Text(
                "Credit:  ${user.credit}",
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => logOut(),
                child: Text('Log Out'),
              ),
            ],
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
