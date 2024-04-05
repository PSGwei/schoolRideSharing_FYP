// import 'dart:async';
// import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:school_ride_sharing/models/carpool.dart';
// import 'package:school_ride_sharing/models/online_drivers.dart';
// import 'package:school_ride_sharing/provider/current_user_provider.dart';
// import 'package:school_ride_sharing/utilities/global_variables.dart';

// StreamSubscription<Position>? positionStreamHomePage;

// class MapDisplay extends ConsumerStatefulWidget {
//   const MapDisplay({
//     super.key,
//     required this.carpool,
//   });

//   final Carpool carpool;

//   @override
//   ConsumerState<MapDisplay> createState() => _MapDisplayState();
// }

// class _MapDisplayState extends ConsumerState<MapDisplay> {
//   GoogleMapController? controllerGoogleMap;
//   Position? currentPositionOfUser;
//   BitmapDescriptor? carIconNearbyDriver;
//   late Marker driverMarker;
//   LatLng? driverCurrentLocation;
//   late OnlineDriver onlineDriver;
//   static const LatLng library = LatLng(4.3399217, 101.1433978);
//   static const LatLng mcd = LatLng(4.326304, 101.144709);
//   Map<PolylineId, Polyline> polylines = {};

//   List<LatLng> routeCoordinates = [];

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   listenDriverCurrentLocation();
//   //   getPolylinePoints().then(
//   //     (coordinates) => generatePolyLineFromPoints(coordinates),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     Position? currentPositionOfUser = ref.watch(currentLocationProvider);

//     void listenDriverCurrentLocation() async {
//       Geofire.initialize("onlineDrivers");

//       if (currentPositionOfUser != null) {
//         // set initial location
//         Geofire.setLocation(
//           FirebaseAuth.instance.currentUser!.uid,
//           currentPositionOfUser!.latitude,
//           currentPositionOfUser!.longitude,
//         );

//         // update the latest location to real-time database
//         positionStreamHomePage = Geolocator.getPositionStream().listen(
//           (Position position) {
//             currentPositionOfUser = position;
//             Geofire.setLocation(
//               FirebaseAuth.instance.currentUser!.uid,
//               currentPositionOfUser!.latitude,
//               currentPositionOfUser!.longitude,
//             );
//             LatLng positionLatLng =
//                 LatLng(position.latitude, position.longitude);
//             controllerGoogleMap!
//                 .animateCamera(CameraUpdate.newLatLng(positionLatLng));
//           },
//         );
//       } else {
//         print('Failed to get location');
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Real-time Tracking'),
//       ),
//       body: currentPositionOfUser == null
//           ? const Center(
//               child: Text('Loading...'),
//             )
//           : Column(
//               children: [
//                 Expanded(
//                   child: GoogleMap(
//                     mapType: MapType.normal,
//                     myLocationEnabled: true,
//                     zoomControlsEnabled: true,
//                     initialCameraPosition: malaysiaPosition,
//                     onMapCreated: (GoogleMapController mapController) async {
//                       controllerGoogleMap = mapController;
//                       // googleMapCompleterController.complete(controllerGoogleMap);
//                       // getCurrentLiveLocationOfUser();
//                       listenDriverCurrentLocation();
//                     },
//                     markers: {
//                       Marker(
//                         markerId: MarkerId('currentLocation'),
//                         icon: BitmapDescriptor.defaultMarkerWithHue(
//                             BitmapDescriptor.hueBlue),
//                         // icon: carIconNearbyDriver!,
//                         position: LatLng(currentPositionOfUser.latitude,
//                             currentPositionOfUser.longitude),
//                       ),
//                       const Marker(
//                           markerId: MarkerId('souceLocation'),
//                           icon: BitmapDescriptor.defaultMarker,
//                           position: library),
//                       const Marker(
//                           markerId: MarkerId('destinationLocation'),
//                           icon: BitmapDescriptor.defaultMarker,
//                           position: mcd),
//                     },
//                     polylines: Set<Polyline>.of(polylines.values),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   // Future<void> fetchDriverLocation() async {
//   //   // get current driver location
//   //   Map<String, dynamic> response =
//   //       await Geofire.getLocation(widget.carpool.uid);
//   //   if (response['error'] == null) {
//   //     double lat = double.tryParse(response['lat'].toString()) ?? 0.0;
//   //     double lng = double.tryParse(response['lng'].toString()) ?? 0.0;
//   //     setState(() {
//   //       onlineDriver = OnlineDriver(
//   //           uidDriver: widget.carpool.uid, latDriver: lat, lngDriver: lng);
//   //     });
//   //   }
//   // }

//   Future<List<LatLng>> getPolylinePoints() async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleMapKey,
//       PointLatLng(
//           driverCurrentLocation!.latitude, driverCurrentLocation!.longitude),
//       PointLatLng(mcd.latitude, mcd.longitude),
//       travelMode: TravelMode.driving,
//     );

//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     } else {
//       print(result.errorMessage);
//     }
//     setState(() {
//       routeCoordinates = polylineCoordinates;
//     });
//     return polylineCoordinates;
//   }

//   void generatePolyLineFromPoints(List<LatLng> polyLineCoordinates) async {
//     PolylineId id = PolylineId('poly');
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.green,
//       points: polyLineCoordinates,
//       width: 8,
//     );
//     setState(() {
//       polylines[id] = polyline;
//     });
//   }
// }
