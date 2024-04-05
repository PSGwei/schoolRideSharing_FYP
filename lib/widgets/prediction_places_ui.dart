import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/models/address.dart';
import 'package:school_ride_sharing/models/prediction_places.dart';
import 'package:school_ride_sharing/provider/address_provider.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';
import 'package:school_ride_sharing/widgets/loading_dialog.dart';

class PredictionPlacesUI extends ConsumerStatefulWidget {
  final PredictionPlaces predictionPlaces;
  final Function(Address) onSelectPlace;

  const PredictionPlacesUI({
    super.key,
    required this.predictionPlaces,
    required this.onSelectPlace,
  });

  @override
  ConsumerState<PredictionPlacesUI> createState() => _PredictionPlacesUIState();
}

class _PredictionPlacesUIState extends ConsumerState<PredictionPlacesUI> {
  void fetchPlaceDetails(String placeId) async {
    String placeDetailsAPIUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&key=$googleMapKey";

    showDialog(
      context: context,
      builder: (context) => LoadingDialog(messageText: 'Getting details....'),
    );

    final response = await sendRequestToAPI(placeDetailsAPIUrl);

    if (!context.mounted) return;
    Navigator.pop(context);

    if (response != 'error') {
      if (response['status'] == 'OK') {
        Address dropOffLocation = Address(
          humanReadableAddress: response['result']['formatted_address'],
          latitude:
              response['result']['geometry']['location']['lat'].toString(),
          longitude:
              response['result']['geometry']['location']['lng'].toString(),
          placeID: placeId,
          placeName: response['result']['name'],
        );

        ref
            .read(dropOffLocationProvider.notifier)
            .updateDropOffLocation(dropOffLocation);

        widget.onSelectPlace(dropOffLocation);

        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => AddCarpool()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        fetchPlaceDetails(widget.predictionPlaces!.placeId.toString());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: Container(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.share_location,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 13,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictionPlaces!.mainText.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.predictionPlaces!.secondaryText.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
