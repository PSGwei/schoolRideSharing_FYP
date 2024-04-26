import 'package:flutter/material.dart';

class AvailableSeatUI extends StatelessWidget {
  const AvailableSeatUI({
    super.key,
    required this.availableSeat,
    required this.totalSeat,
  });

  final int availableSeat;
  final int totalSeat;

  @override
  Widget build(BuildContext context) {
    List<Icon> seatIcons = [];
    for (int i = 0; i < totalSeat - 1; i++) {
      seatIcons.add(
        Icon(
          i < availableSeat ? Icons.chair_outlined : Icons.chair_rounded,
          size: 50,
        ),
      );
    }
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.amberAccent,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 200,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      availableSeat < totalSeat
                          ? Icons.chair_rounded
                          : Icons.chair_outlined,
                      size: 50,
                    ),
                    Image.asset(
                      'assets/images/car_steering_wheel.png',
                      width: 80,
                      height: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: seatIcons,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
