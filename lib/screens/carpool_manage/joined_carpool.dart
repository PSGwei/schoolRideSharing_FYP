import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/screens/carpool_manage/carpool_detail.dart';
import 'package:school_ride_sharing/widgets/carpool_card.dart';
import 'package:school_ride_sharing/widgets/loading_indicator.dart';

class JoinedCarpool extends StatelessWidget {
  const JoinedCarpool({super.key});

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('carpools')
          .where('status', isEqualTo: false)
          .where('participants', arrayContains: currentUserId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator(
              message: 'Loading data...'); // Your loading widget
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Error handling
        }
        if (!snapshot.hasData) {
          return const Text('No data available'); // No data found
        }

        final docs = snapshot.data!.docs;
        List<Carpool> carpools = docs
            .map((doc) =>
                Carpool.toCarpoolModel(doc.data() as Map<String, dynamic>))
            .toList();

        if (carpools.isEmpty) {
          return const Center(
            child: Text(
              'Not yet join any carpool.',
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CarpoolDetail(carpool: carpools[index]),
                  ),
                );
              },
              child: CarpoolCard(carpool: carpools[index]),
            );
          },
        );
      },
    );
  }
}
