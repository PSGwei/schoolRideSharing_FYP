import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/provider/username_provider.dart';

class CarpoolDetail extends ConsumerWidget {
  const CarpoolDetail({
    super.key,
    required this.carpoolId,
  });

  final String carpoolId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Carpool Detail')),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('carpools').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No data yet'),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }

            final carpools = snapshot.data!.docs;
            QueryDocumentSnapshot currentCarpool = carpools.firstWhere(
              (carpool) => carpool.get('id') == carpoolId,
            );

            final List<String> participants =
                List<String>.from(currentCarpool.get('participants'));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('participants:'),
                ...participants.map((participant) {
                  final AsyncValue<String> usernameAsyncValue =
                      ref.watch(usernameProvider(participant));
                  return usernameAsyncValue.when(
                      data: (username) => Text(username),
                      error: (e, _) => Text('Error: $e'),
                      loading: () => const CircularProgressIndicator());
                }),
              ],
            );
          }),
    );
  }
}
