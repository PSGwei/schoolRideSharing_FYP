import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/provider/user_provider.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';

// User? currentUser = CommonMethods.getCurrentUser();

class RequestDetail extends ConsumerWidget {
  const RequestDetail({
    super.key,
    required this.carpool,
  });

  final Carpool carpool;

  String get locationImage {
    // Calculate the midpoint latitude and longitude
    double centerLatitude = (double.parse(carpool.pickUp.latitude) +
            double.parse(carpool.destination.latitude)) /
        2;
    double centerLongitude = (double.parse(carpool.pickUp.latitude) +
            double.parse(carpool.destination.longitude)) /
        2;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${centerLatitude},${centerLongitude}=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C${carpool.pickUp.latitude},${carpool.pickUp.longitude}&markers=color:blue%7Clabel:B%7C${carpool.destination.latitude},${carpool.destination.longitude}&key=$googleMapKey';
  }

  void onSendRequest(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user!.uid != carpool.uid) {
      try {
        await FirebaseFirestore.instance.collection('requests').add({
          'carpool_id': carpool.id,
          'owner_id': carpool.uid,
          'requester_id': user.uid,
          'status': 'pending',
        });
        if (!context.mounted) return;
        displaySnackbar('request was sent', context);
      } catch (error) {}
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider(carpool.uid));

    return Scaffold(
      appBar: AppBar(title: null),
      body: Column(
        children: [
          Container(
            height: 150,
            color: Colors.amberAccent,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                ),
                Column(
                  children: [
                    userAsyncValue.when(
                      data: (user) => Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(user.username),
                                SizedBox(width: 20),
                                Text(user.gender),
                              ],
                            ),
                            Row(
                              children: [Text(user.credit.toString())],
                            ),
                          ],
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) =>
                          const Text('Something went wrong'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  onSendRequest(context);
                },
                icon: Icon(Icons.tab),
                label: const Text('Request to join'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.abc),
                label: const Text('Message'),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(CupertinoIcons.smallcircle_fill_circle),
              Expanded(
                child: Text(
                  carpool.pickUp.humanReadableAddress,
                  style: TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(CupertinoIcons.location_solid),
              Expanded(
                  child: Text(
                carpool.destination.humanReadableAddress,
                style: TextStyle(overflow: TextOverflow.ellipsis),
              )),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Image.network(
              locationImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
