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
import 'package:school_ride_sharing/screens/upload_evidence.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';
import 'package:school_ride_sharing/models/user.dart' as models;
import 'package:school_ride_sharing/widgets/loading_indicator.dart';
import 'package:school_ride_sharing/widgets/tracking_dashboard.dart';
import 'package:http/http.dart' as http;

StreamSubscription<Position>? positionStreamHomePage;

class MapDisplay extends ConsumerStatefulWidget {
  const MapDisplay(
      {super.key, required this.carpool, required this.passengers});

  final Carpool carpool;
  final List<models.User> passengers;

  @override
  ConsumerState<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends ConsumerState<MapDisplay> {
  GoogleMapController? controllerGoogleMap;
  Position? driverCurrentPosition;
  LatLng? driverCurrentLatLng;

  Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> routeCoordinates = [];

  List<models.User> passengers = [];
  int currentDestinationIndex = 0;

  bool isCurrentRouteComplete = false;
  bool isAllRouteCompleted = false;
  bool isRouteLoading = false;

  late LatLng targetDestination;
  late LatLng carpoolDestination;

  List<LatLng> destionationList = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    passengers = widget.passengers;

    initializeDriverLocation().then((_) {
      setState(() {
        isRouteLoading = true; // Start showing the loading indicator
      });
      sortPassengersByRouteDistance().then(
        (_) => setLocationMarkers().then(
          (_) => getPolylinePoints()
              .then(
            (coordinates) => generatePolyLineFromPoints(coordinates),
          )
              .then(
            (_) {
              setState(() {
                isRouteLoading = false; // Start showing the loading indicator
              });
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    print("MapDisplay2 dispose started");
    controllerGoogleMap?.dispose();
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
          ? const Center(child: LoadingIndicator(message: 'Loading the map...'))
          : driverCurrentPosition == null
              ? const Center(child: Text('Loading...'))
              : buildMap(),
    );
  }

  Widget buildMap() {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: malaysiaPosition,
          onMapCreated: (GoogleMapController mapController) {
            controllerGoogleMap = mapController;
            listenDriverCurrentLocation();
          },
          markers: markers,
          polylines: Set<Polyline>.of(polylines.values),
        ),
        buildTrackingSheet(),
      ],
    );
  }

  Widget buildTrackingSheet() {
    return DraggableScrollableSheet(
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
              // isCurrentRouteComplete: isCurrentRouteComplete,
              passenger: passengers[index],
            ),
          ),
        ),
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
          if (!isAllRouteCompleted) {
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

            bool isOutside = await isLocationOutsideRoute(
                driverCurrentLatLng!, routeCoordinates);
            if (isOutside) {
              // Stop the location updates
              await positionStreamHomePage?.cancel();
              positionStreamHomePage = null;
              // Show alert dialog
              if (!context.mounted) return;
              showCustomDialog(context, 'Route Deviation Alert',
                  'Warning: The driver has deviated from the planned route.');
            }

            await checkProximityToDestination(driverCurrentLatLng!);

            print("update map position");

            CameraPosition cameraPosition =
                CameraPosition(target: driverCurrentLatLng!, zoom: 16);

            // update map camera to current position
            try {
              if (!mounted)
                return; // Checks if the widget is still in the widget tree
              if (driverCurrentLatLng != null && controllerGoogleMap != null) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 3000), () {
                  controllerGoogleMap!.animateCamera(
                      CameraUpdate.newCameraPosition(cameraPosition));
                });
              }
            } catch (e) {
              print('Failed to animate camera: $e');
            }
          }
        },
      );
    } else {
      print('Failed to get location');
    }
  }

  Future<void> checkProximityToDestination(LatLng driverCurrentLocation) async {
    if (currentDestinationIndex < destionationList.length) {
      LatLng targetDestination = destionationList[currentDestinationIndex];

      double distance = Geolocator.distanceBetween(
        driverCurrentLocation.latitude,
        driverCurrentLocation.longitude,
        targetDestination.latitude,
        targetDestination.longitude,
      );

      if (currentDestinationIndex == destionationList.length - 1 &&
          distance <= 50.0) {
        await onAllRoutesCompleted();
      } else if (distance <= 50.0) {
        setState(() {
          currentDestinationIndex++;
        });
        await navigateToNextPassenger();
      }
    }
  }

  Future<void> navigateToNextPassenger() async {
    if (currentDestinationIndex < destionationList.length) {
      if (currentDestinationIndex == destionationList.length - 1) {
        showCustomDialog(context, 'Arrival',
            'All kids fetched completed. Going to School....');
      } else {
        showCustomDialog(context, 'Arrival',
            "You have reached your destination. Preparing the next route.");
      }

      LatLng targetDestination = destionationList[currentDestinationIndex];
      setState(() {
        isRouteLoading = true;
      });

      await updateRoute(driverCurrentLatLng!, targetDestination);

      setState(() {
        isRouteLoading = false;
      });
    }
  }

  Future<bool> isLocationOutsideRoute(
      LatLng userLocation, List<LatLng> pathPoints) async {
    double minDistance = double.infinity;
    //findNearestPointDistance
    for (var point in pathPoints) {
      double distance = Geolocator.distanceBetween(userLocation.latitude,
          userLocation.longitude, point.latitude, point.longitude);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance > 100; // Assuming 100 meters as the threshold
  }

  Future<void> onAllRoutesCompleted() async {
    isAllRouteCompleted = true;

    // Cancel the position listener
    if (positionStreamHomePage != null) {
      await positionStreamHomePage!.cancel();
      positionStreamHomePage = null;
      controllerGoogleMap?.dispose();
      Geofire.removeLocation(widget.carpool.uid);
    }

    if (!context.mounted) return;
    showCustomDialog(
        context, 'Arrival', 'Carpool completed. Navigating to another page...',
        onDismissed: onDialogDismissed);
  }

  void onDialogDismissed() {
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => UploadEvidence(
              carpool: widget.carpool,
            )));
  }

  Future<void> updateRoute(LatLng start, LatLng destination) async {
    // Ensure GoogleMapController is not disposed and is still valid
    if (controllerGoogleMap == null) {
      print('GoogleMapController is not initialized or has been disposed.');
      return;
    }

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
      setState(() {
        routeCoordinates = polylineCoordinates;
      });
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

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapKey,
        PointLatLng(
            driverCurrentLatLng!.latitude, driverCurrentLatLng!.longitude),
        PointLatLng(double.parse(passengers[0].defaultAddress!.latitude),
            double.parse(passengers[0].defaultAddress!.longitude)),
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
    } catch (e) {
      print(e.toString());
    }

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

  Future<void> setLocationMarkers() async {
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

  void showCustomDialog(BuildContext context, String title, String message,
      {VoidCallback? onDismissed}) {
    showDialog(
      context: context,
      // Dialog is dismissible with a tap on the barrier
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.red.shade600,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                if (onDismissed != null) {
                  onDismissed();
                }
              },
              child: const Text(
                'Okay',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
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

      setState(() {
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
      });
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
