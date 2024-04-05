class Address {
  String humanReadableAddress;
  String longitude;
  String latitude;
  String placeID;
  String placeName;

  Address({
    required this.humanReadableAddress,
    required this.latitude,
    required this.longitude,
    required this.placeID,
    required this.placeName,
  });

  Map<String, dynamic> toJson() => {
        "humanReadableAddress": humanReadableAddress,
        "longitude": longitude,
        "latitude": latitude,
        "placeID": placeID,
        "placeName": placeName,
      };

  static Address toAddressModel(Map<String, dynamic> snapshot) {
    return Address(
      humanReadableAddress: snapshot['humanReadableAddress'],
      longitude: snapshot['longitude'],
      latitude: snapshot['latitude'],
      placeID: snapshot['placeID'],
      placeName: snapshot['placeName'],
    );
  }

  static Address emptyAddress() {
    return Address(
      humanReadableAddress: '',
      longitude: '',
      latitude: '',
      placeID: '',
      placeName: '',
    );
  }
}
