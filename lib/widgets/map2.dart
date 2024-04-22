import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/screens/testing2.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';
import 'package:school_ride_sharing/models/user.dart' as models;
import 'package:school_ride_sharing/widgets/loading_indicator.dart';
import 'package:school_ride_sharing/widgets/tracking_dashboard.dart';
import 'package:http/http.dart' as http;

StreamSubscription<Position>? positionStreamHomePage;

class MapDisplay2 extends ConsumerStatefulWidget {
  const MapDisplay2(
      {super.key, required this.carpool, required this.passengers});

  final Carpool carpool;
  final List<models.User> passengers;

  @override
  ConsumerState<MapDisplay2> createState() => _MapDisplayState();
}

class _MapDisplayState extends ConsumerState<MapDisplay2> {
  GoogleMapController? controllerGoogleMap;
  Position? driverCurrentPosition;
  LatLng? driverCurrentLatLng;

  Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> routeCoordinates = [];

  List<models.User> passengers = [];
  int currentDestinationIndex = 0;

  bool isCurrentRouteComplete = false;
  bool isAllPsgCompleted = false;
  bool isRouteLoading = false;

  late LatLng targetDestination;
  late LatLng carpoolDestination;

  List<LatLng> destionationList = [];

  @override
  void initState() {
    super.initState();
    passengers = widget.passengers;

    // currentPassengerLatitude = double.parse(
    //     passengers[currentPassengerIndex].defaultAddress!.latitude);
    // currentPassengerLongitude = double.parse(
    //     passengers[currentPassengerIndex].defaultAddress!.longitude);

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

    initializeDriverLocation().then((_) {
      setState(() {
        isRouteLoading = true; // Start showing the loading indicator
      });
      sortPassengersByRouteDistance().then(
        (_) => updatePassengerMarkers().then(
          (_) => getPolylinePoints()
              .then(
            (coordinates) => generatePolyLineFromPoints(coordinates),
          )
              .then(
            (_) {
              setState(() {
                isRouteLoading = false; // Start showing the loading indicator
              });
              // listenDriverCurrentLocation();
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    positionStreamHomePage?.cancel();
    Geofire.removeLocation(widget.carpool.uid);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Tracking'),
      ),
      body: isRouteLoading
          ? Center(
              child: LoadingIndicator(
              message: 'Loading the map....',
            ))
          : driverCurrentPosition == null
              ? const Center(
                  child: Text('Loading...'),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      zoomControlsEnabled: true,
                      initialCameraPosition: malaysiaPosition,
                      onMapCreated: (GoogleMapController mapController) async {
                        controllerGoogleMap = mapController;
                        // googleMapCompleterController.complete(controllerGoogleMap);
                        // getCurrentLiveLocationOfUser();
                        // await listenDriverCurrentLocation();
                        // await getPolylinePoints().then((coordinates) =>
                        //     generatePolyLineFromPoints(coordinates));
                        listenDriverCurrentLocation();
                      },
                      markers: markers,
                      polylines: Set<Polyline>.of(polylines.values),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.15,
                      minChildSize: 0.15,
                      maxChildSize: 0.45,
                      builder: (context, controller) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          color: Colors.black87,
                          child: ListView.builder(
                            controller: controller,
                            itemCount: widget.carpool.participants.length,
                            itemBuilder: (context, index) => TrackingDashbaord(
                              onGoingIndex: currentDestinationIndex,
                              index: index,
                              isCurrentRouteComplete: isCurrentRouteComplete,
                              passenger: passengers[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> listenDriverCurrentLocation() async {
    Geofire.initialize("onlineDrivers");

    if (driverCurrentPosition != null) {
      // set initial location
      Geofire.setLocation(
        FirebaseAuth.instance.currentUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      // update the latest location to real-time database
      positionStreamHomePage = Geolocator.getPositionStream().listen(
        (Position position) async {
          driverCurrentPosition = position;

          setState(() {
            driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude);
          });

          Geofire.setLocation(
            FirebaseAuth.instance.currentUser!.uid,
            driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude,
          );

          await checkProximityToDestination(driverCurrentLatLng!);

          // update map camera to current position
          CameraPosition cameraPosition =
              CameraPosition(target: driverCurrentLatLng!, zoom: 15);
          controllerGoogleMap!
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        },
      );
    } else {
      print('Failed to get location');
    }
  }

  Future<void> checkProximityToDestination(LatLng driverCurrentLocation) async {
    if (currentDestinationIndex < passengers.length) {
      LatLng targetDestination = destionationList[currentDestinationIndex];

      double distance = Geolocator.distanceBetween(
        driverCurrentLocation.latitude,
        driverCurrentLocation.longitude,
        targetDestination.latitude,
        targetDestination.longitude,
      );

      // print(
      //     'currentDestinationIndex in checkProximity: $currentDestinationIndex');
      // print('targetDestination in checkProximity: $targetDestination');

      if (distance <= 50.0) {
        // 100 meters proximity threshold
        currentDestinationIndex++;
        await navigateToNextPassenger();
      }
    }
  }

  Future<void> navigateToNextPassenger() async {
    if (currentDestinationIndex < destionationList.length) {
      // if (!context.mounted) return;
      showCustomDialog(context,
          "You have reached your destination. Preparing the next route.");
      if (currentDestinationIndex == destionationList.length - 1) {
        // if (!context.mounted) return;
        showCustomDialog(
            context, 'All kids fetched completed. Going to School....');
      }

      LatLng targetDestination = destionationList[currentDestinationIndex];
      setState(() {
        isRouteLoading = true; // Start showing the loading indicator
      });

      await updateRoute(driverCurrentLatLng!, targetDestination);

      setState(() {
        isRouteLoading = false; // Start showing the loading indicator
      });
    } else {
      // await onAllRoutesCompleted();
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyWidget()));
    }
  }

  Future<void> onAllRoutesCompleted() async {
    // Show completion dialog
    if (!context.mounted) return;
    showCustomDialog(context, 'All routes completed. Ending the ride.');

    // Cancel the position listener
    await positionStreamHomePage?.cancel();
    positionStreamHomePage = null;

    // Optionally, navigate to another screen or perform other cleanup
  }

  Future<void> updateRoute(LatLng start, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates =
            result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

        // Clear existing polylines (to remove the previous route from the map)
        polylines.clear();
      } else {
        print(result.errorMessage);
      }
    } catch (e) {
      print("Failed to fetch route: $e");
    }

    // Add new polyline
    PolylineId id = PolylineId('route${destination.hashCode}');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoordinates,
      width: 8,
    );

    setState(() {
      polylines[id] = polyline; // Replace old polylines with the new one
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapKey,
      PointLatLng(
          driverCurrentLatLng!.latitude, driverCurrentLatLng!.longitude),
      PointLatLng(destionationList[0].latitude, destionationList[0].longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }
    setState(() {
      routeCoordinates = polylineCoordinates;
    });
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polyLineCoordinates) async {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polyLineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> updatePassengerMarkers() async {
    final newMarkers = <Marker>{}; // Temporary set to hold new markers
    for (var passenger in widget.passengers) {
      LatLng passengerPosition = LatLng(
          double.parse(passenger.defaultAddress!.latitude),
          double.parse(passenger.defaultAddress!.longitude));

      Marker passengerMarker = Marker(
          markerId:
              MarkerId(passenger.uid), // Assume each passenger has a unique id
          position: passengerPosition,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
              title: passenger.username) // Optional: shows name on tap
          );

      newMarkers.add(passengerMarker);
    }
    newMarkers.add(
      Marker(
        markerId: const MarkerId('driverCurrentLocation'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        // icon: carIconNearbyDriver!,
        position: driverCurrentLatLng!,
      ),
    );
    newMarkers.add(
      Marker(
        markerId: const MarkerId('carpoolDestination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        // icon: carIconNearbyDriver!,
        position: carpoolDestination,
      ),
    );
    setState(() {
      markers = newMarkers; // Replace old markers with new ones
    });
  }

  Future<void> initializeDriverLocation() async {
    // get driver current position
    try {
      driverCurrentPosition = await Geolocator.getCurrentPosition();

      setState(() {
        driverCurrentLatLng = LatLng(
            driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      });
    } catch (e) {
      print('Failed to get initial location: $e');
    }
  }

  void showCustomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Arrival"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sortPassengersByRouteDistance() async {
    if (driverCurrentLatLng != null) {
      Map<models.User, int> passengerDistances = {};
      for (var passenger in passengers) {
        LatLng passengerLatLng = LatLng(
          double.parse(passenger.defaultAddress!.latitude),
          double.parse(passenger.defaultAddress!.longitude),
        );

        try {
          int distance =
              await fetchRouteDistance(driverCurrentLatLng!, passengerLatLng);
          passengerDistances[passenger] = distance;
        } catch (error) {
          print(
              "Error fetching distance for passenger ${passenger.uid}: $error");
          passengerDistances[passenger] = 0; // Assign max distance on error
        }
      }

      // Sort passengers after all distances are fetched
      passengers.sort((a, b) {
        int distA = passengerDistances[a] ?? 0;
        int distB = passengerDistances[b] ?? 0;
        return distA.compareTo(distB);
      });

      setState(() {});
    }
  }

  Future<int> fetchRouteDistance(LatLng origin, LatLng destination) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleMapKey';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['routes'] != null && jsonResponse['routes'].isNotEmpty) {
        var route = jsonResponse['routes'][0];
        var leg = route['legs'][0];
        int distance = leg['distance']['value']; // Distance in meters
        return distance;
      }
    }
    throw Exception('Failed to load directions');
  }
}
