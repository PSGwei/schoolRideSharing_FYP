import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/models/user.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';

class Testing extends StatefulWidget {
  const Testing({
    super.key,
    required this.carpool,
    required this.passengers,
  });

  final Carpool carpool;
  final List<User> passengers;

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Marker? _driverMarker;

  late BitmapDescriptor markerIcon;
  late final Marker convertedMarker;
  Set<Marker> markers = {};

  LatLng? driverCurrentLatLng;
  late LatLng carpoolDestination;

  @override
  void initState() {
    super.initState();

    carpoolDestination = LatLng(
      double.parse(widget.carpool.destination.latitude),
      double.parse(widget.carpool.destination.longitude),
    );

    generateMarker();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      initialCameraPosition: malaysiaPosition,
      onMapCreated: (GoogleMapController mapController) {
        controllerGoogleMap = mapController;
        googleMapCompleterController.complete(controllerGoogleMap);
        trackDriver();
      },
      markers: _driverMarker != null ? {_driverMarker!} : {},
    );
  }

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // await initializeGeoFireListener();
  }

  void trackDriver() async {
    DatabaseReference dbRef =
        _database.child('onlineDrivers/${widget.carpool.uid}/l');

    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as List;
      final double lat = data[0] as double;
      final double lng = data[1] as double;
      final LatLng position = LatLng(lat, lng);

      setState(() {
        _driverMarker = Marker(
          markerId: const MarkerId('driver'),
          position: position,
          icon: markerIcon,
        );
      });

      controllerGoogleMap?.animateCamera(CameraUpdate.newLatLng(position));
    });
  }

  Future<void> setLocationMarkers() async {
    if (driverCurrentLatLng != null) {
      final newMarkers = <Marker>{}; // Temporary set to hold new markers
      for (var passenger in widget.passengers) {
        LatLng passengerPosition = LatLng(
            double.parse(passenger.defaultAddress!.latitude),
            double.parse(passenger.defaultAddress!.longitude));

        Marker passengerMarker = Marker(
            markerId: MarkerId(
                passenger.uid), // Assume each passenger has a unique id
            position: passengerPosition,
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
                title: passenger.username) // Optional: shows name on tap
            );

        newMarkers.add(passengerMarker);
      }
      newMarkers.add(
        Marker(
          markerId: const MarkerId('carpoolDestination'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          // icon: carIconNearbyDriver!,
          position: carpoolDestination,
        ),
      );
      setState(() {
        markers = newMarkers; // Replace old markers with new ones
      });
    }
  }

  void generateMarker() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(0.5, 0.5)),
      'assets/images/tracking.png',
    );
  }
}
