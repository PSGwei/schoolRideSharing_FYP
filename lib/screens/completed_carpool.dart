import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/widgets/carpool_card.dart';
import 'package:school_ride_sharing/widgets/loading_indicator.dart';
import 'package:school_ride_sharing/widgets/show_completed_photo.dart';

class CompletedCarpool extends StatelessWidget {
  const CompletedCarpool({super.key});

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Create two separate streams for the two conditions
    var stream1 = FirebaseFirestore.instance
        .collection('carpools')
        .where('status', isEqualTo: true)
        .where('participants', arrayContains: currentUserId)
        .snapshots();

    var stream2 = FirebaseFirestore.instance
        .collection('carpools')
        .where('status', isEqualTo: true)
        .where('uid', isEqualTo: currentUserId)
        .snapshots();

    // Combine the two streams
    var combinedStream = CombineLatestStream.list([stream1, stream2])
        .map((List<QuerySnapshot> snapshotList) {
      // Combine the list of documents from both snapshots
      var allDocs = {...snapshotList[0].docs, ...snapshotList[1].docs};
      return allDocs
          .map((doc) =>
              Carpool.toCarpoolModel(doc.data() as Map<String, dynamic>))
          .toList();
    });

    return StreamBuilder<List<Carpool>>(
      stream: combinedStream,
      builder: (BuildContext context, AsyncSnapshot<List<Carpool>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator(message: 'Loading data...');
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Error handling
        }
        if (!snapshot.hasData) {
          return const Text('No data available'); // No data found
        }

        List<Carpool> carpools = snapshot.data!;

        if (carpools.isEmpty) {
          return const Center(
            child: Text(
              'No completed carpool record yet.',
              style: TextStyle(
                fontSize: 20,
              ),
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
