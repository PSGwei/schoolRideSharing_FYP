import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:school_ride_sharing/models/address.dart';
import 'package:school_ride_sharing/provider/address_provider.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';

checkConnectivity(BuildContext context) async {
  var connectionResult = await Connectivity().checkConnectivity();
  if (connectionResult != ConnectivityResult.mobile &&
      connectionResult != ConnectivityResult.wifi) {
    if (!context.mounted) {
      return;
    }
    displaySnackbar('Internet connnection is not available', context);
  }
}

void displaySnackbar(String message, BuildContext context) {
  var snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

sendRequestToAPI(String apiURL) async {
  try {
    Response response = await get(Uri.parse(apiURL));
    if (response.statusCode == 200) {
      String result = response.body;
      var decodedResult = jsonDecode(result);
      return decodedResult;
    }
  } catch (error) {
    return 'error';
  }
}

Future<String> reverseGeoCoding(Position position, WidgetRef ref) async {
  String result = 'Something went wrong';
  String apiURL =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey';

  final response = await sendRequestToAPI(apiURL);

  if (response != 'error') {
    String humanReadableAddress = response['results'][0]['formatted_address'];
    String placeID = response['results'][0]['place_id'];

    Address pickUpAddress = Address(
      placeID: placeID,
      placeName: '',
      humanReadableAddress: humanReadableAddress,
      latitude: position.latitude.toString(),
      longitude: position.longitude.toString(),
    );
    ref
        .read(pickUpLocationProvider.notifier)
        .updatePickUpLocation(pickUpAddress);
    result = 'Success';
  }
  return result;
}

Future<String> searchLocation(
    String originPlaceID, String destinationPlaceID) async {
  String result = 'Error';
  String distanceAPIUrl =
      "https://maps.googleapis.com/maps/api/distancematrix/json?destinations=place_id:$destinationPlaceID&origins=place_id:$originPlaceID&key=$googleMapKey";
  final response = await sendRequestToAPI(distanceAPIUrl);
  if (response != 'error') {
    if (response["status"] == 'OK') {
      final elements = response['rows'][0]['elements'];
      if (elements[0]["status"] == 'OK') {
        final String distanceText = elements[0]['distance']['text'];
        return distanceText;
      }
    }
  }
  return result;
}

Future<Uint8List> loadProjectImageBytes(String imagePath) async {
  final ByteData data = await rootBundle.load(imagePath);
  return data.buffer.asUint8List();
}
