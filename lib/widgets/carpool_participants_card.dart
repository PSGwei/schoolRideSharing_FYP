import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/models/user.dart' as models;
import 'package:school_ride_sharing/provider/user_provider.dart';
import 'package:school_ride_sharing/widgets/real-time_tracking_map.dart';
import 'package:school_ride_sharing/widgets/te.dart';

import 'carpool_participant_container.dart';

class CarpoolParticipantCard extends ConsumerStatefulWidget {
  const CarpoolParticipantCard({
    super.key,
    required this.participants,
    required this.carpool,
  });

  final List<models.User> participants;
  final Carpool carpool;

  @override
  ConsumerState<CarpoolParticipantCard> createState() =>
      _CarpoolParticipantCardState();
}

class _CarpoolParticipantCardState
    extends ConsumerState<CarpoolParticipantCard> {
  final currentUserID = FirebaseAuth.instance.currentUser!.uid;
  bool isParticipant = false;

  @override
  void initState() {
    super.initState();
    for (models.User participant in widget.participants) {
      if (participant.uid == currentUserID) {
        isParticipant = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<models.User> ownerAsyncValue =
        ref.watch(userProvider(widget.carpool.uid));

    double height = MediaQuery.of(context).size.height;

    return Container(
      height: height / 2,
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  height: 130,
                  color: Colors.amber,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Driver: ',
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit),
                          ),
                        ],
                      ),
                      Center(
                        child: ownerAsyncValue.when(
                          data: (models.User user) =>
                              CarpoolParticipantContainer(
                            user: user,
                            carpool: widget.carpool,
                          ),
                          loading: () => const Text('Loading...'),
                          error: (e, _) => const Text('Something went wrong'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 130,
                  padding: EdgeInsets.all(10.0),
                  color: Colors.deepPurple.shade200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Passengers: ',
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ...widget.participants.map(
                            (participant) => CarpoolParticipantContainer(
                              user: participant,
                              carpool: widget.carpool,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => isParticipant
                            ? Testing(
                                carpool: widget.carpool,
                                passengers: widget.participants,
                              )
                            : MapDisplay(
                                carpool: widget.carpool,
                                passengers: widget.participants,
                              ),
                      ),
                    );
                  },
                  child: isParticipant
                      ? const Text('Join!')
                      : const Text('Start!'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
