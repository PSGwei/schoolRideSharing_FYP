import 'package:flutter/material.dart';
import 'package:school_ride_sharing/models/user.dart';
import 'package:shimmer/shimmer.dart';

class TrackingDashbaord extends StatelessWidget {
  const TrackingDashbaord({
    super.key,
    required this.onGoingIndex,
    required this.index,
    required this.isCurrentRouteComplete,
    required this.passenger,
  });

  final int onGoingIndex;
  final int index;
  final bool isCurrentRouteComplete;
  final User passenger;

  @override
  Widget build(BuildContext context) {
    return onGoingIndex == index
        ? Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.black87,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '${index + 1}: Going to ${passenger.username}\'s house ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              '${index + 1}: Going to ${passenger.username}\'s house ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          );
  }
}
