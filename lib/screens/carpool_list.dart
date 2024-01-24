import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/screens/carpool_manage/carpool_detail.dart';
import 'package:school_ride_sharing/screens/carpool_list_detail.dart';

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

          final user = FirebaseAuth.instance.currentUser;

          Iterable<Carpool> carpools = snapshot.data!.docs.map((document) {
            Map<String, dynamic> data = document.data();
            return Carpool.fromFireStore(data);
          });

          if (isMyCarpoolPage) {
            carpoolList = carpools
                .where((carpool) => carpool.user.uid == user!.uid)
                .toList();
          } else {
            carpoolList = carpools.toList();
          }

          if (carpoolList.isEmpty) {
            return const Center(
              child: Text('Empty'),
            );
          }

          return ListView.builder(
            itemCount: carpoolList.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => isMyCarpoolPage
                        ? CarpoolDetail(
                            carpoolId: carpoolList[index].id,
                          )
                        : RequestDetail(
                            carpool: carpoolList[index],
                          ),
                  ),
                );
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: const EdgeInsets.all(10),
                color: Colors.amber,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                        ),
                        Column(
                          children: [
                            Text(carpoolList[index].user.userName),
                            Row(
                              children: [
                                Text(carpoolList[index].date),
                                const SizedBox(width: 20),
                                Text(carpoolList[index].time),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.smallcircle_fill_circle),
                        Text(carpoolList[index].pickUp),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.location_solid),
                        Text(carpoolList[index].destination),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
