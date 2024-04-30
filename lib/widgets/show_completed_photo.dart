import 'package:flutter/material.dart';
import 'package:school_ride_sharing/models/carpool.dart';

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
                Image.network(carpool.imageURL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
