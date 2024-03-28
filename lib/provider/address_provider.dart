import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_ride_sharing/models/address.dart';

class PickUpAddressStateNotifier extends StateNotifier<Address?> {
  PickUpAddressStateNotifier() : super(null);

  void updatePickUpLocation(Address address) {
    state = address;
  }
}

class DropOffAddressStateNotifier extends StateNotifier<Address?> {
  DropOffAddressStateNotifier() : super(null);

  void updateDropOffLocation(Address address) {
    state = address;
  }
}

final pickUpLocationProvider =
    StateNotifierProvider<PickUpAddressStateNotifier, Address?>(
  (ref) => PickUpAddressStateNotifier(),
);

final dropOffLocationProvider =
    StateNotifierProvider<DropOffAddressStateNotifier, Address?>(
  (ref) => DropOffAddressStateNotifier(),
);
