import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/assistants/request_assistant.dart';
import 'package:rider_app/models/address_model.dart';
import 'package:rider_app/models/all_users.dart';
import 'package:rider_app/models/direction_details.dart';
import 'package:rider_app/providers/app_data.dart';

import '../config_maps.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, BuildContext context) async {
    String placeAddress = '';
    String st1 = '', st2 = '', st3 = '', st4 = '';
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapAPIkey';
    var response = await RequestAssistant.getRequest(url);
    if (response != 'Failed') {
      // placeAddress =response['results'][0]['address_components'][3]['long_name'];
      st1 = response['results'][0]['address_components'][0]['long_name'];
      st2 = response['results'][0]['address_components'][1]['long_name'];
      st3 = response['results'][0]['address_components'][2]['long_name'];
      //st4= response['results'][0]['address_components'][6]!=null? response['results'][0]['address_components'][6]['long_name']:'' ;
      placeAddress = st1 + ', ' + st2 + ', ' + st3;
      AddressModel userPickupAddress = AddressModel();
      userPickupAddress.latitude = position.latitude;
      userPickupAddress.longitude = position.longitude;
      userPickupAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updatePickupLocationAddress(userPickupAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionsDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapAPIkey';
    var response = await RequestAssistant.getRequest(url);
    if (response == 'failed') {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];

    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        (response['routes'][0]['legs'][0]['distance']['value']);

    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        (response['routes'][0]['legs'][0]['duration']['value']);

    return directionDetails;
  }

  static int calcilateFares(DirectionDetails directionDetails) {
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
    double distanceTraveledFare =
        (directionDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    double localAmount = totalFareAmount * 15.5;
    return localAmount.truncate();
  }

  static void getUserInformation() async {
    firebaseuser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseuser.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('users').child(userId);
    reference.once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value!= null){
        userCurrentInfo= Users.fromSnapshot(dataSnapshot);
      }
    });
  }
}
