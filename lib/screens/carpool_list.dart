import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/provider/current_user_provider.dart';
import 'package:school_ride_sharing/screens/request_detail.dart';
import 'package:school_ride_sharing/screens/carpool_manage/carpool_detail.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/widgets/carpool_card.dart';
import 'package:school_ride_sharing/widgets/loading_indicator.dart';

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
  bool isLoadingPosition = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocationOfUser();
  }

  void getCurrentLocationOfUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled; prompt the user to enable them.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, prompt the user to allow permissions from the app settings.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, prompt the user to enable them in the app settings.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // dont set at above getting permission
    setState(() {
      isLoadingPosition = true;
    });

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    ref.read(currentLocationProvider.notifier).updateCurrentLocation(position);
    await reverseGeoCoding(position, ref);

    setState(() {
      currentPositionOfUser = position; // Update position
      isLoadingPosition = false; // End loading
    });
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
            return const LoadingIndicator(
              message: 'Getting the data...',
            );
          }

          if (isLoadingPosition) {
            const LoadingIndicator(
              message: 'Getting the location...',
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
                            carpool: carpoolList[index],
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
