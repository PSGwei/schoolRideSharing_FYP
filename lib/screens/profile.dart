import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/methods/common_methods.dart';
import 'package:school_ride_sharing/provider/username_provider.dart';
import 'package:school_ride_sharing/screens/authentication/authentication.dart';

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
      CommonMethods.checkConnectivity(context);
      await FirebaseAuth.instance.signOut();
      // force the provider to re-evaluate its future and fetch the new username
      //ref.refresh(usernameProvider(user.uid));
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
