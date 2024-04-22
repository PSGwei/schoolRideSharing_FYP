// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:school_ride_sharing/models/carpool.dart';
// import 'package:school_ride_sharing/models/user.dart' as models;

// void main() {
//   runApp(MaterialApp(home: MapDisplay()));
// }

// class MapDisplay extends StatefulWidget {
//   @override
//   _MapDisplayState createState() => _MapDisplayState();
// }

// class _MapDisplayState extends State<MapDisplay> {
//   GoogleMapController? mapController;
//   List<models.User> passengers = [
//     models.User(username: "Alice", latitude: "4.3401", longitude: "101.1408"),
//     models.User(username: "Bob", latitude: "4.3421", longitude: "101.1429"),
//   ]; // Sample passenger data
//   int currentPassengerIndex = 0;
//   LatLng? driverCurrentLocation;
//   Map<PolylineId, Polyline> polylines = {};
//   StreamSubscription<Position>? positionStream;

//   @override
//   void initState() {
//     super.initState();
//     initLocationService();
//   }

//   @override
//   void dispose() {
//     positionStream?.cancel();
//     super.dispose();
//   }

//   Future<void> initLocationService() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return; // Permissions are denied, next step is to inform the user and request permission again.
//       }
//     }

//     positionStream = Geolocator.getPositionStream().listen(
//       (Position position) {
//         setState(() {
//           driverCurrentLocation = LatLng(position.latitude, position.longitude);
//         });
//         checkProximityToDestination(driverCurrentLocation!);
//       },
//     );
//   }

//   void checkProximityToDestination(LatLng currentPosition) {
//     if (currentPassengerIndex < passengers.length) {
//       LatLng nextDestination = LatLng(
//         double.parse(passengers[currentPassengerIndex].latitude),
//         double.parse(passengers[currentPassengerIndex].longitude),
//       );

//       double distance = Geolocator.distanceBetween(
//         currentPosition.latitude,
//         currentPosition.longitude,
//         nextDestination.latitude,
//         nextDestination.longitude,
//       );

//       if (distance <= 50.0) {
//         // 50 meters proximity threshold
//         navigateToNextPassenger();
//       }
//     }
//   }

//   void navigateToNextPassenger() {
//     if (currentPassengerIndex < passengers.length) {
//       LatLng nextDestination = LatLng(
//         double.parse(passengers[currentPassengerIndex].latitude),
//         double.parse(passengers[currentPassengerIndex].longitude),
//       );
//       updateRoute(driverCurrentLocation!, nextDestination);
//       currentPassengerIndex++;
//     } else {
//       print("All passengers have been navigated to.");
//     }
//   }

//   Future<void> updateRoute(LatLng start, LatLng destination) async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       "YOUR_GOOGLE_API_KEY", // Insert your Google Maps API Key here
//       PointLatLng(start.latitude, start.longitude),
//       PointLatLng(destination.latitude, destination.longitude),
//       travelMode: TravelMode.driving,
//     );

//     if (result.points.isNotEmpty) {
//       polylineCoordinates =
//           result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
//     } else {
//       print(result.errorMessage);
//     }

//     setState(() {
//       polylines[PolylineId('route')] = Polyline(
//         polylineId: PolylineId('route'),
//         color: Colors.green,
//         points: polylineCoordinates,
//         width: 8,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Real-time Tracking"),
//       ),
//       body: driverCurrentLocation == null
//           ? Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               mapType: MapType.normal,
//               initialCameraPosition: CameraPosition(
//                 target: driverCurrentLocation!,
//                 zoom: 14.0,
//               ),
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               polylines: Set<Polyline>.of(polylines.values),
//               onMapCreated: (GoogleMapController controller) {
//                 mapController = controller;
//               },
//             ),
//     );
//   }
// }

// class User {
//   final String username;
//   final String latitude;
//   final String longitude;

//   User(
//       {required this.username,
//       required this.latitude,
//       required this.longitude});
// }
