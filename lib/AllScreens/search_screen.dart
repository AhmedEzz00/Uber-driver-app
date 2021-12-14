import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/assistants/request_assistant.dart';
import 'package:rider_app/config_maps.dart';
import 'package:rider_app/models/address_model.dart';
import 'package:rider_app/models/place_predictions.dart';
import 'package:rider_app/providers/app_data.dart';
import 'package:rider_app/widgets/devider.dart';
import 'package:rider_app/widgets/prediction_tile.dart';
import 'package:rider_app/widgets/search_for_place.dart';

class SearchScreen extends StatefulWidget {
  static String screenName = 'search screen';
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AppData _appData;

  @override
  void initState() {
    super.initState();
    _appData = Provider.of<AppData>(context, listen: false);

    /* WidgetsBinding.instance!.addPostFrameCallback((_) {
    });*/
  }

  TextEditingController pickupController = TextEditingController();
  TextEditingController dropOffContriler = TextEditingController();

  List<dynamic> placesList = [];
  //List<PlacePrediction> placePredictionsList;

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context, listen: false).userPickupLocation != null
            ? Provider.of<AppData>(context, listen: false)
                .userPickupLocation
                .placeName
                .toString()
            : '';
    if (placeAddress != '') {
      pickupController.text = placeAddress.toString();
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 215.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7)),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.0, top: 20.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                        Center(
                          child: Text(
                            'Set Drop off',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontFamily: 'Brand Bold',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    SearchForPlace(
                      controller: pickupController,
                      hint: 'Pick up location',
                      image: 'assets/images/pickicon.png',
                    ),
                    SizedBox(
                      height: 16.0,
                    ),

                    //dropoff search textfield

                    Consumer<AppData>(
                        builder: (context, provider, _) => SearchForPlace(
                              onChanged: (value) {
                                provider.placeAutoComplete(value);
                                // placesList = provider.placesList;
                              },
                              controller: dropOffContriler,
                              hint: 'Where to?',
                              image: 'assets/images/desticon.png',
                            ))

                    /*  SearchForPlace(
                      onChanged: (value) {
                        findPlace(value);
                      },
                      controller: dropOffContriler,
                      hint: 'Where to?',
                      image: 'assets/images/desticon.png',
                    )*/
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Consumer<AppData>(builder: (context, provider, _) {
                  return provider.placesList.length > 0
                      ? ListView.separated(
                          itemBuilder: (context, index) {
                            return PredictionTile(
                                mainText: (provider.placesList[index]
                                        ['structured_formatting']['main_text'])
                                    .toString(),
                                secondaryText: (provider.placesList[index]
                                        ['structured_formatting']
                                        ['secondary_text']
                                    .toString()),
                                onTap: () {
                                  getPlaceAddressDetails(
                                      provider.placesList[index]['place_id'],
                                      context);
                                });
                          },
                          separatorBuilder: (context, index) => deviderWidget(),
                          itemCount: provider.placesList.length)
                      : Container();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, BuildContext context) async {
    String placeAddressDetails =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapAPIkey';
    var response = await RequestAssistant.getRequest(placeAddressDetails);
    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      AddressModel address = AddressModel();
      address.placeName = response['result']['name'];
      address.placeId = response['result']['place_id'];
      address.latitude = response['result']['geometry']['location']['lat'];
      address.longitude = response['result']['geometry']['location']['lng'];
      Provider.of<AppData>(context, listen: false)
          .updateDropoffLocationAddress(address);

      Navigator.pop(context, 'obtainDirection');
    }
  }
}
