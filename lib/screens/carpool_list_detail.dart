import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/methods/common_methods.dart';
import 'package:school_ride_sharing/models/carpool.dart';

// User? currentUser = CommonMethods.getCurrentUser();

class RequestDetail extends StatelessWidget {
  const RequestDetail({
    super.key,
    required this.carpool,
  });

  final Carpool carpool;

  void onSendRequest(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user!.uid != carpool.user.uid) {
      try {
        await FirebaseFirestore.instance.collection('requests').add({
          'carpool_id': carpool.id,
          'owner_id': carpool.user.uid,
          'requester_id': user.uid,
          'status': 'pending',
        });
        if (!context.mounted) return;
        CommonMethods.displaySnackbar('request was sent', context);
      } catch (error) {}
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(carpool.user.userName),
                    Text(carpool.user.gender),
                    Text(carpool.user.credit.toString()),
                    Text('other information'),
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
              Text(carpool.pickUp),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(CupertinoIcons.location_solid),
              Text(carpool.destination),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
          ),
        ],
      ),
    );
  }
}
