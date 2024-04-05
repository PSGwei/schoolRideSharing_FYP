import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/provider/user_id_provider.dart';
import 'package:school_ride_sharing/provider/username_provider.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class MyRequest extends ConsumerWidget {
  const MyRequest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider).asData?.value;
    void deleteRequest(String requestId) async {
      await firestore.collection('requests').doc(requestId).delete();
    }

    void acceptRequest(
        String carpoolId, String requesterId, String requestId) async {
      // get the participants of the carpool
      final carpool = await firestore
          .collection('carpools')
          .where('id', isEqualTo: carpoolId)
          .limit(1)
          .get();

      if (carpool.docs.isNotEmpty) {
        // update the participants data
        List<String> participants =
            List<String>.from(carpool.docs[0].get('participants'));
        participants.add(requesterId);

        await carpool.docs[0].reference.update({
          'participants': participants,
        });

        deleteRequest(requestId);

        displaySnackbar('Accepted Request', context);
      } else {
        if (!context.mounted) return;
        displaySnackbar('Document doesn\'t exist', context);
      }
    }

    return StreamBuilder(
      stream: (userId != null)
          ? FirebaseFirestore.instance
              .collection('requests')
              .where('owner_id', isEqualTo: userId)
              .snapshots()
          : const Stream.empty(),
      builder: ((context, snapshot) {
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

        final loadedRequests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: loadedRequests.length,
          itemBuilder: (context, index) {
            final requesterId = loadedRequests[index].get('requester_id');
            final requesterUsername = ref.watch(usernameProvider(requesterId));

            return ListTile(
              leading: const CircleAvatar(
                radius: 30,
              ),
              title: requesterUsername.when(
                data: (requesterUsername) =>
                    Text('$requesterUsername has sent you a carpool request'),
                error: (e, st) => Text('Error: $e'),
                loading: () => const SizedBox(),
              ),
              trailing: Container(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          acceptRequest(
                            loadedRequests[index].data()['carpool_id'],
                            loadedRequests[index].data()['requester_id'],
                            loadedRequests[index].id,
                          );
                        },
                        icon: const Icon(Icons.check)),
                    IconButton(
                        onPressed: () {
                          deleteRequest(loadedRequests[index].id);
                        },
                        icon: const Icon(Icons.close)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
