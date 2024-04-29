import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';

class CompletePhotoDisplay extends StatelessWidget {
  const CompletePhotoDisplay({
    super.key,
    required this.carpool,
  });

  final Carpool carpool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your kids have arrived to school safely',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 30),
                Image.asset('assets/images/kid_dropoff.jpg'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
