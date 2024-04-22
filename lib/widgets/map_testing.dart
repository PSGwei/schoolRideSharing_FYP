import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';

class MapTesting extends StatefulWidget {
  const MapTesting({Key? key}) : super(key: key);

  @override
  State<MapTesting> createState() => _MapTestingState();
}

class _MapTestingState extends State<MapTesting> {
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  LatLng? driverCurrentLocation; // Initial location
  static const LatLng mcd = LatLng(4.326304, 101.144709);
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    fetchAndSimulateRoute()
        .then((coordinates) => generatePolyLineFromPoints(coordinates));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Tracking'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        initialCameraPosition: malaysiaPosition,
        onMapCreated: (GoogleMapController mapController) {
          controllerGoogleMap = mapController;
        },
        markers: {
          if (currentPositionOfUser != null)
            Marker(
              markerId: const MarkerId('currentLocation'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position: LatLng(currentPositionOfUser!.latitude,
                  currentPositionOfUser!.longitude),
            ),
          const Marker(
            markerId: MarkerId('sourceLocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(4.3399217, 101.1433978),
          ),
          const Marker(
            markerId: MarkerId('destinationLocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: mcd,
          ),
        },
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }

  Future<List<LatLng>> fetchAndSimulateRoute() async {
    List<LatLng> routePoints = [];
    PolylinePoints polylinePoints = PolylinePoints();

    currentPositionOfUser = await Geolocator.getCurrentPosition();
    driverCurrentLocation = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapKey,
      PointLatLng(
          driverCurrentLocation!.latitude, driverCurrentLocation!.longitude),
      PointLatLng(mcd.latitude, mcd.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      routePoints = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      simulateMovement(routePoints);
    } else {
      print("No points found for the route");
    }
    setState(() {
      routeCoordinates = routePoints;
    });
    return routePoints;
  }

  void simulateMovement(List<LatLng> routePoints) {
    int index = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (index < routePoints.length) {
        LatLng simulatedPosition = routePoints[index];
        setState(() {
          currentPositionOfUser = Position(
            latitude: simulatedPosition.latitude,
            longitude: simulatedPosition.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 5000,
            speedAccuracy: 0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
          driverCurrentLocation = simulatedPosition;
        });
        controllerGoogleMap!
            .animateCamera(CameraUpdate.newLatLng(simulatedPosition));
        index++;
      } else {
        timer.cancel();
      }
    });
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
}
