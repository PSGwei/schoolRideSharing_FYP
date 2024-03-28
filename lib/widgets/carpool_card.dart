import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/provider/user_provider.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';

class CarpoolCard extends ConsumerWidget {
  const CarpoolCard({
    super.key,
    required this.carpool,
  });

  final Carpool carpool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider(carpool.uid));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.all(10),
      color: Colors.amber,
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(defaultAvatar),
              ),
              Column(
                children: [
                  userAsyncValue.when(
                    data: (user) => Text(user.username),
                    loading: () => const Text('Loading...'),
                    error: (e, _) => const Text('Something went wrong'),
                  ),
                  Row(
                    children: [
                      Text(carpool.date),
                      const SizedBox(width: 20),
                      Text(carpool.time),
                    ],
                  ),
                ],
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
          Row(
            children: [
              const Icon(CupertinoIcons.location_solid),
              Expanded(
                child: Text(
                  carpool.destination.humanReadableAddress,
                  style: TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                carpool.distance,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
