class PredictionPlaces {
  String? placeId;
  String? mainText;
  String? secondaryText;

  PredictionPlaces({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  PredictionPlaces.toModel(Map<String, dynamic> data) {
    placeId = data['place_id'];
    mainText = data['structured_formatting']['main_text'];
    secondaryText = data['structured_formatting']['secondary_text'];
  }
}
