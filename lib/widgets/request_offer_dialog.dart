import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:school_ride_sharing/screens/search_destination_page.dart';

class RequestOrOfferDialog extends StatelessWidget {
  const RequestOrOfferDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min, //restrict the container size
        children: [
          Image.asset(
            'assets/images/confused.png',
            height: 100,
            // width: 50,
          ),
          const SizedBox(height: 20),
          const Text(
            'Would you like to offer a carpool or request a carpool?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                // width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const SearchDestinationPage(
                              // isOffer: true,
                              )),
                    );
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  child: const Text('Offer'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         const SearchDestinationPage(isOffer: false),
                  //   ),
                  // );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                child: const Text('Request'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
