import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/models/user.dart' as models;
import 'package:school_ride_sharing/utilities/global_variables.dart';
import 'package:school_ride_sharing/widgets/tracking_dashboard.dart';

class Testing extends StatefulWidget {
  const Testing({
    super.key,
    required this.carpool,
    required this.passengers,
  });

  final Carpool carpool;
  final List<models.User> passengers;

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  late BitmapDescriptor markerIcon;
  Set<Marker> markers = {};

  LatLng? driverCurrentLatLng;
  late LatLng carpoolDestination;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> routeCoordinates = [];

  List<models.User> passengers = [];

  List<LatLng> destionationList = [];

  int? currentDestinationIndex;

  @override
  void initState() {
    super.initState();

    passengers = widget.passengers;

    carpoolDestination = LatLng(
      double.parse(widget.carpool.destination.latitude),
      double.parse(widget.carpool.destination.longitude),
    );

    for (var i in passengers) {
      destionationList.add(LatLng(
        double.parse(i.defaultAddress!.latitude),
        double.parse(i.defaultAddress!.longitude),
      ));
    }
    destionationList.add(carpoolDestination);

    generateMarker();
    process();
  }

  void process() async {
    await getDriverLocationOnce();
    await setLocationMarkers();
    await checkProximity();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: malaysiaPosition,
          onMapCreated: (GoogleMapController mapController) {
            controllerGoogleMap = mapController;
            googleMapCompleterController.complete(controllerGoogleMap);
            trackDriver();
          },
          markers: markers,
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.2,
          minChildSize: 0.15,
          maxChildSize: 0.45,
          builder: (context, controller) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: currentDestinationIndex != null
                ? Container(
                    padding: const EdgeInsets.all(10.0),
                    color: Colors.black87,
                    child: ListView.builder(
                      controller: controller,
                      itemCount: widget.carpool.participants.length,
                      itemBuilder: (context, index) => TrackingDashbaord(
                        onGoingIndex: currentDestinationIndex!,
                        index: index,
                        passenger: passengers[index],
                      ),
                    ),
                  )
                : Container(),
          ),
        )
      ],
    );
  }

  Future<void> checkProximity() async {
    if (driverCurrentLatLng == null)
      return; // Ensure the driver's location is available

    double minDistance = double.infinity;
    LatLng? nearestDestination;
    int? nearestIndex; // To store the index of the nearest destination

    for (int i = 0; i < destionationList.length - 1; i++) {
      LatLng destination = destionationList[i];
      double distance = Geolocator.distanceBetween(
        driverCurrentLatLng!.latitude,
        driverCurrentLatLng!.longitude,
        destination.latitude,
        destination.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestDestination = destination;
        nearestIndex = i; // Save the index of the nearest destination
      }
    }

    // Now, `nearestDestination` holds the closest destination to the driver
    // `nearestIndex` holds the index of this destination in the list
    if (nearestDestination != null && nearestIndex != null) {
      print(
          "Nearest destination is at index $nearestIndex, located at: $nearestDestination with a distance of $minDistance meters");

      // Optional: Update UI or state if needed
      setState(() {
        currentDestinationIndex = nearestIndex!;
        // Update some state if required, such as highlighting the nearest destination on the map
      });
    }
  }

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 16);
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

      addOrUpdateMarker(const MarkerId('driver'), position, icon: markerIcon);

      setState(() {
        driverCurrentLatLng = position;
      });

      controllerGoogleMap?.animateCamera(CameraUpdate.newLatLng(position));
    });
  }

  Future<void> setLocationMarkers() async {
    if (driverCurrentLatLng != null) {
      final newMarkers = <Marker>{}; // Temporary set to hold new markers
      for (var passenger in widget.passengers) {
        if (passenger.uid == FirebaseAuth.instance.currentUser!.uid) {
          continue;
        }
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
          position: carpoolDestination,
        ),
      );
      newMarkers.add(
        Marker(
          markerId: const MarkerId('driverMarker'),
          icon: markerIcon,
          position: driverCurrentLatLng!,
        ),
      );
      setState(() {
        markers = newMarkers; // Replace old markers with new ones
      });
    }
  }

  Future<void> getDriverLocationOnce() async {
    DatabaseReference dbRef =
        _database.child('onlineDrivers/${widget.carpool.uid}/l');

    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as List;
      final double lat = data[0] as double;
      final double lng = data[1] as double;
      final LatLng position = LatLng(lat, lng);

      setState(() {
        driverCurrentLatLng = position;
      });
    }
  }

  void addOrUpdateMarker(MarkerId markerId, LatLng position,
      {BitmapDescriptor? icon}) {
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      icon: icon ?? BitmapDescriptor.defaultMarker,
    );

    setState(() {
      // add the marker to the set if it is new, or update it if it exists.
      markers.removeWhere((m) => m.markerId == markerId);
      markers.add(marker);
    });
  }

  void generateMarker() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(0.5, 0.5)),
      'assets/images/tracking.png',
    );
  }
}
