import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/widgets/carpool_card.dart';

class CarpoolsScreen extends StatelessWidget {
  const CarpoolsScreen({
    super.key,
    required this.isMyCarpoolPage,
  });

  final bool isMyCarpoolPage;

  @override
  Widget build(BuildContext context) {
    List<Carpool> carpoolList;

    return StreamBuilder(
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

          Iterable<Carpool> carpools = snapshot.data!.docs.map((document) {
            Map<String, dynamic> data = document.data();
            return Carpool.toCarpoolModel(data);
          });

          carpoolList = carpools.toList();
/*
          if (isMyCarpoolPage) {
            carpoolList = carpools
                .where((carpool) => carpool.user.uid == user!.uid)
                .toList();
          } else {
            carpoolList = carpools.toList();
          }

          if (snapshot.) {
            return const Center(
              child: Text('Empty'),
            );
          }
          */

// InkWell(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => isMyCarpoolPage
//                         ? CarpoolDetail(
//                             carpoolId: carpoolList[index].id,
//                           )
//                         : RequestDetail(
//                             carpool: carpoolList[index],
//                           ),
//                   ),
//                 );
//               },
//             ),

          return ListView.builder(
            itemCount: carpoolList.length,
            itemBuilder: (context, index) =>
                CarpoolCard(carpool: carpoolList[index]),
          );
        });
  }
}
