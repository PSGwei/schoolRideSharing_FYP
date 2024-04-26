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
    return FutureBuilder(
        future: fetchImageUrl('carpools', 'evidence', carpool.id),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data!.isNotEmpty) {
            return Center(
              child: Container(
                child: Image.network(snapshot.data!),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading the image: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
