import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/widgets/carpool_card.dart';
import 'package:school_ride_sharing/widgets/loading_indicator.dart';
import 'package:school_ride_sharing/widgets/show_completed_photo.dart';

class CompletedCarpool extends StatelessWidget {
  const CompletedCarpool({super.key});

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Assuming that you want to fetch carpools where the current user is either a participant
    // or the owner (uid) and the status is true.
    var completedCarpoolsStream = FirebaseFirestore.instance
        .collection('carpools')
        .where('status', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Carpool.toCarpoolModel(doc.data());
      }).where((carpool) {
        // Filter to include only those carpools where the current user is the owner
        // or a participant.
        return carpool.uid == currentUserId ||
            carpool.participants.contains(currentUserId);
      }).toList();
    });

    return StreamBuilder<List<Carpool>>(
      stream: completedCarpoolsStream,
      builder: (BuildContext context, AsyncSnapshot<List<Carpool>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator(message: 'Loading data...');
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('No data available');
        }

        List<Carpool> carpools = snapshot.data!;

        if (carpools.isEmpty) {
          return const Center(
            child: Text(
              'No completed carpool records yet.',
              style: TextStyle(fontSize: 20),
            ),
          );
        }

        return ListView.builder(
          itemCount: carpools.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CompletePhotoDisplay(
                          carpool: carpools[index],
                        )));
              },
              child: CarpoolCard(carpool: carpools[index]),
            );
          },
        );
      },
    );
  }
}
