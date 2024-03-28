import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

const String defaultAvatar = 'assets/images/avatarman.png';

const Uuid uuid = Uuid();

const String googleMapKey = 'AIzaSyAmmCIkD5pjX_2Igrn7IfNdteJY0InaSiM';

const CameraPosition googlePlexInitial = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
