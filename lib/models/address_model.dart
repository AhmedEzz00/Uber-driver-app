class AddressModel {
  String placeFormattedAddress;
  String placeName;
  String placeId;
  double latitude;
  double longitude;

  AddressModel(
      {this.latitude,
      this.longitude,
      this.placeFormattedAddress,
      this.placeId,
      this.placeName});
}
