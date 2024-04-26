import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:school_ride_sharing/models/address.dart';
import 'package:school_ride_sharing/models/prediction_places.dart';
import 'package:school_ride_sharing/provider/address_provider.dart';
import 'package:school_ride_sharing/screens/add_carpool.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';
import 'package:school_ride_sharing/widgets/prediction_places_ui.dart';

class SearchDestinationPage extends ConsumerStatefulWidget {
  const SearchDestinationPage({
    super.key,
  });

  @override
  ConsumerState<SearchDestinationPage> createState() =>
      _SearchDestinationPageState();
}

class _SearchDestinationPageState extends ConsumerState<SearchDestinationPage> {
  final TextEditingController pickUpTextEditingController =
      TextEditingController();

  final TextEditingController destinationTextEditingController =
      TextEditingController();

  Position? currentPositionOfUser;
  late Address dropOffAddress;
  List<PredictionPlaces> destinationPredictionList = [];
  bool isSucess = true;

  void searchLocation(String locationName, Address userLocation,
      [int radius = 1000]) async {
    if (locationName.length > 1) {
      String apiPlaceUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&location=${userLocation.latitude}%2C${userLocation.longitude}&radius=$radius&key=$googleMapKey";
      final response = await sendRequestToAPI(apiPlaceUrl);
      if (response != 'error') {
        if (response["status"] == 'OK') {
          final predictionResultInJson = response['predictions'];
          final predictionPlaces = (predictionResultInJson as List)
              .map((place) => PredictionPlaces.toModel(place))
              .toList();
          setState(() {
            destinationPredictionList = predictionPlaces;
          });
        }
      }
    } else {
      setState(() {
        destinationPredictionList.clear();
        isSucess = false;
      });
    }
  }

  void updateDestination(Address selectedPlaceDetails) {
    setState(() {
      dropOffAddress = selectedPlaceDetails;
      destinationTextEditingController.text =
          selectedPlaceDetails.humanReadableAddress;
      destinationPredictionList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    //anytime the pickUpLocationProvider's humanReadableAddress changes, the widget rebuilds
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final Address? pickUpAddress = ref.watch(pickUpLocationProvider);

    if (pickUpAddress != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          pickUpTextEditingController.text = pickUpAddress.humanReadableAddress;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Dropoff Location'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddCarpool(
                              pickUpLocation: pickUpAddress!,
                              dropOffLocation: dropOffAddress,
                            )));
              },
              child: const Text('Next')),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  top: 48,
                  right: 24,
                  bottom: 48,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/initial.png',
                          height: 30,
                          width: 30,
                        ),
                        Expanded(
                          child: Container(
                            // color: Colors.grey,
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: const InputDecoration(
                                hintText: 'Pickup Address',
                                fillColor: Colors.white12,
                                filled: true,
                                // border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/final.png',
                          height: 30,
                          width: 30,
                        ),
                        Expanded(
                          child: Container(
                            // color: Colors.grey,
                            child: TextField(
                              controller: destinationTextEditingController,
                              onChanged: (value) {
                                searchLocation(value, pickUpAddress!);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Destination Address',
                                fillColor: Colors.white12,
                                filled: true,
                                // border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (destinationPredictionList.isNotEmpty || isSucess)
                ? Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace),
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: ListView.separated(
                          itemBuilder: ((context, index) {
                            return Card(
                              elevation: 3,
                              child: PredictionPlacesUI(
                                predictionPlaces:
                                    destinationPredictionList[index],
                                onSelectPlace: updateDestination,
                              ),
                            );
                          }),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 2),
                          itemCount: destinationPredictionList.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Text('No result found'),
                  )
          ],
        ),
      ),
    );
  }
}
