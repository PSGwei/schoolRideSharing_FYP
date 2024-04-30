import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/models/user.dart';
import 'package:school_ride_sharing/utilities/authentication_method.dart';
import 'package:school_ride_sharing/widgets/carpool_participants_card.dart';

class CarpoolDetail extends ConsumerWidget {
  const CarpoolDetail({
    super.key,
    required this.carpool,
  });

  final Carpool carpool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> participantsID = List<String>.from(carpool.participants);

    // Future<List<User>> participantsFuture =
    //     AuthMethods().getUserDetails2(participantsID);

    Stream<List<User>> participantsStream =
        AuthMethods().getUserDetailsStream(carpool.participants);

    return Scaffold(
      appBar: AppBar(title: Text('Carpool Detail')),
      body: StreamBuilder<List<User>>(
        stream: participantsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No participants found'),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          List<User> participants = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: CarpoolParticipantCard(
              participants: participants,
              carpool: carpool,
            ),
          );
        },
      ),
    );
  }
}
