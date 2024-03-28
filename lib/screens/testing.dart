import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';

class Testing extends ConsumerStatefulWidget {
  const Testing({super.key});

  @override
  ConsumerState<Testing> createState() => _TestingState();
}

class _TestingState extends ConsumerState<Testing> {
  //GoogleMapController is only available after the map has been created.
  // final Completer<GoogleMapController> googleMapCompleterController =
  //     Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;

  Position? currentPositionOfUser;

  getCurrentLiveLocationOfUser() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = position;
    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await reverseGeoCoding(position, ref);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      initialCameraPosition: googlePlexInitial,
      onMapCreated: (GoogleMapController mapController) {
        controllerGoogleMap = mapController;
        // googleMapCompleterController.complete(controllerGoogleMap);
        getCurrentLiveLocationOfUser();
      },
    );
  }
}
