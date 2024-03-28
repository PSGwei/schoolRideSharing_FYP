import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/screens/carpool_list_detail.dart';
import 'package:school_ride_sharing/screens/carpool_manage/carpool_detail.dart';
import 'package:school_ride_sharing/screens/carpool_manage/my_request.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/widgets/carpool_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.isMyCarpoolPage,
  });

  final bool isMyCarpoolPage;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Position? currentPositionOfUser;
  List<Carpool> carpoolList = [];

  @override
  void initState() {
    super.initState();
    getCurrentLiveLocationOfUser();
  }

  void getCurrentLiveLocationOfUser() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    if (!context.mounted) return;
    currentPositionOfUser = position;
    await reverseGeoCoding(position, ref);
  }

  void removeItem(Carpool carpool) async {
    setState(() {
      carpoolList.remove(carpool);
    });
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('carpools').doc(carpool.id).delete();
    displaySnackbar('Carpool deleted sucessfully', context);
  }

  @override
  Widget build(BuildContext context) {
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
            return Carpool.toCarpoolModel(data);
          });

          if (widget.isMyCarpoolPage) {
            carpoolList =
                carpools.where((carpool) => carpool.uid == user!.uid).toList();
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
                    builder: (context) => widget.isMyCarpoolPage
                        ? CarpoolDetail(
                            carpoolId: carpoolList[index].id,
                          )
                        : RequestDetail(
                            carpool: carpoolList[index],
                          ),
                  ),
                );
              },
              child: Dismissible(
                key: ValueKey(carpoolList[index].id),
                onDismissed: (direction) {
                  removeItem(carpoolList[index]);
                },
                child: CarpoolCard(carpool: carpoolList[index]),
              ),
            ),
          );
        });
  }
}
