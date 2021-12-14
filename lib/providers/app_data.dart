import 'package:flutter/cupertino.dart';
import 'package:rider_app/assistants/request_assistant.dart';
import 'package:rider_app/config_maps.dart';
import 'package:rider_app/models/address_model.dart';

class AppData extends ChangeNotifier {
  
  AddressModel userPickupLocation, userDropoffLocation;
  List<dynamic> placesList= [];

  void updatePickupLocationAddress(AddressModel pickupAddress){
    userPickupLocation= pickupAddress;
    notifyListeners();
  }

    void updateDropoffLocationAddress(AddressModel dropOffAddress){
    userDropoffLocation= dropOffAddress;
    notifyListeners();
  }

   void placeAutoComplete(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapAPIkey&sessiontoken=1234567890&components=country:eg';
      var response = await RequestAssistant.getRequest(autoCompleteUrl);
      if (response == 'failed') {
        return;
      }
     // print(
     //     '//////////////////////////////////////////////////////////////////////////');

      if (response['status'] == 'OK') {
       // print(
       //     '//////////////////////////////////////////////////////////////////////////');
        var predictions = response['predictions'];
        placesList = (predictions as List);
        /* .map((e) => PlacePrediction.fromJson(e))
         .toList();*/
        //placePredictionsList = placesList;
       // print(placesList[0]['structured_formatting']['main_text']);
      }
      notifyListeners();
    }
  }

}