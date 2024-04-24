import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_ride_sharing/screens/authentication.dart';
import 'package:school_ride_sharing/screens/tabs.dart';
import 'package:school_ride_sharing/screens/upload_evidence.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Permission.locationWhenInUse.isDenied.then((isDenied) {
    if (isDenied) {
      Permission.locationWhenInUse.request();
    }
  });
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
  //           await googleSignIn.disconnect(); //Clear the cached sign-in
  //         }
  //       }
  //     }
  //   }
  // });
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(250, 243, 193, 14)),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // return TabsScreen();
            return UploadEvidence();
            // return SearchDestinationPage();
          }
          return AuthScreen();
        },
      ),
    );
  }
}
