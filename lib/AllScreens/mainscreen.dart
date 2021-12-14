import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllScreens/login_screen.dart';
import 'package:rider_app/AllScreens/search_screen.dart';
import 'package:rider_app/assistants/assistant_methods.dart';
import 'package:rider_app/assistants/request_assistant.dart';
import 'package:rider_app/config_maps.dart';
import 'package:rider_app/models/direction_details.dart';
import 'package:rider_app/providers/app_data.dart';
import 'package:rider_app/widgets/devider.dart';
import 'package:rider_app/widgets/home-work-address.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rider_app/widgets/progress_dialog_widget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class MainScreen extends StatefulWidget {
  static const screenName = 'Main Screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _myController = Completer();
  GoogleMapController _googleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Position currentPosition;
  var geolocator = Geolocator();
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  double bottomPaddingOfMap = 0;
  double rideDetailsContainerHeight = 0.0;
  double searchCotainerHeight = 250.0;
  double requestRideContainerHeight = 0.0;
  DirectionDetails tripDirectionDetails;
  bool drawerOpen = true;
  DatabaseReference rideRequestreference;

  @override
  void initState() {
    AssistantMethods.getUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/user_icon.png',
                        height: 85.0,
                        width: 65.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Profile name',
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: 'Brand-Bold'),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Visit profile',
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              deviderWidget(),
              SizedBox(
                height: 12.0,
              ),

              // drawer body
              ListTile(
                leading: Icon(
                  Icons.history,
                ),
                title: Text(
                  'History',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                ),
                title: Text(
                  'Visit profile',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                ),
                title: Text(
                  'About',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              GestureDetector(
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                  ),
                  title: Text(
                    'Log out',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginScreen.screenName, (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapToolbarEnabled: true,
            padding: EdgeInsets.only(
              bottom: bottomPaddingOfMap,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _myController.complete(controller);
              _googleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 250.0;
              });
              locatePosition();
            },
            polylines: polylineSet,
            markers: markers,
            circles: circles,
          ),

          //handling button for drawer
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    drawerOpen == true ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
              onTap: () {
                if (drawerOpen == true) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
            ),
          ),

          //search container
          Positioned(
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(
                height: searchCotainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          'Hey there!',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        Text(
                          'Where to?',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Bold-Band',
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var res = await Navigator.pushNamed(
                                context, SearchScreen.screenName);
                            if (res == 'obtainDirection') {
                              displayRideDetailsContainer();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 6.0,
                                    spreadRadius: 0.5,
                                    offset: Offset(0.7, 0.7))
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    'Search drop off',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                        homeWorkAddress(
                            maintext: Provider.of<AppData>(context)
                                        .userPickupLocation !=
                                    null
                                ? Provider.of<AppData>(context)
                                    .userPickupLocation
                                    .placeName
                                    .toString()
                                : 'Add home',
                            hintText: 'Your living home address',
                            iconData: Icons.home),
                        SizedBox(
                          height: 10.0,
                        ),
                        deviderWidget(),
                        SizedBox(
                          height: 10.0,
                        ),
                        homeWorkAddress(
                            iconData: Icons.work,
                            maintext: 'Add Work',
                            hintText: 'Office address'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //ride container
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(
                  height: rideDetailsContainerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.blue[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/taxi.png',
                                height: 70.0,
                                width: 90.0,
                              ),
                              SizedBox(width: 16.0),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Car',
                                        style: TextStyle(
                                            fontSize: 25.0,
                                            fontFamily: 'Brand-Bold')),
                                    Text(
                                        (tripDirectionDetails != null
                                            ? ' ${tripDirectionDetails.distanceText} '
                                            : ''),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontFamily: 'Brand-Bold',
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60.0,
                              ),
                              Expanded(
                                  child: Container(
                                child: Text(
                                    (tripDirectionDetails != null
                                        ? '\$${AssistantMethods.calcilateFares(tripDirectionDetails)} '
                                        : ''),
                                    style: TextStyle(
                                        fontSize: 30.0,
                                        fontFamily: 'Brand-Bold',
                                        color: Colors.black)),
                              )),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.solidMoneyBillAlt,
                                size: 18.0, color: Colors.black54),
                            SizedBox(width: 16.0),
                            Text('Cach'),
                            SizedBox(width: 6.0),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.black54, size: 16.0),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            displayRequestRideContainer();
                          },
                          color: Colors.blueAccent,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              5.0,
                              0,
                              5.0,
                              0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Request',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.white,
                                  size: 18.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Signatra',
                            color: Colors.green),
                        child: AnimatedTextKit(
                          isRepeatingAnimation: true,
                          repeatForever: true,
                          animatedTexts: [
                            FadeAnimatedText('Requesting a ride',
                                textAlign: TextAlign.center),
                            FadeAnimatedText('Please wait...',
                                textAlign: TextAlign.center),
                            FadeAnimatedText(
                              'Finding a driver ',
                              textAlign: TextAlign.center,
                            ),
                          ],
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              cancelRideRequest();
                              resetApp();
                            },
                            child: Container(
                              height: 60.0,
                              width: 60.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26.0),
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.grey[400],
                                ),
                              ),
                              child: Icon(Icons.close, size: 26.0),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                              width: double.infinity,
                              child: Text(
                                'Cancel ride',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;

    LatLng latLngPosition = LatLng(
      position.latitude,
      position.longitude,
    );

    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );

    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        cameraPosition,
      ),
    );

  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).userPickupLocation;
    var finalPos =
        Provider.of<AppData>(context, listen: false).userDropoffLocation;
    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);
// set dialoge here
    showDialog(
        context: context,
        builder: (context) {
          return ProgressDialog(
            message: 'Please wait...',
          );
        });
    var details = await AssistantMethods.obtainPlaceDirectionsDetails(
        pickUpLatLng, dropOffLatLng);
    Navigator.pop(context);

    setState(() {
      tripDirectionDetails = details;
    });
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();
    if (decodedPolylinePointResult.isNotEmpty) {
      decodedPolylinePointResult.forEach((PointLatLng pointLatlng) {
        pLineCoordinates
            .add(LatLng(pointLatlng.latitude, pointLatlng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.black,
        polylineId: PolylineId('polylineID'),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: dropOffLatLng,
        northeast: pickUpLatLng,
      );
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          pickUpLatLng.latitude,
          dropOffLatLng.longitude,
        ),
        northeast: LatLng(
          dropOffLatLng.latitude,
          pickUpLatLng.longitude,
        ),
      );
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          dropOffLatLng.latitude,
          pickUpLatLng.longitude,
        ),
        northeast: LatLng(
          pickUpLatLng.latitude,
          dropOffLatLng.longitude,
        ),
      );
    } else {
      latLngBounds = LatLngBounds(
        southwest: pickUpLatLng,
        northeast: dropOffLatLng,
      );
    }
    _googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker picupLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      ),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: 'My location'),
      position: pickUpLatLng,
      markerId: MarkerId('pickupid'),
    );

    Marker dropOffLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: 'Drop off location'),
      position: dropOffLatLng,
      markerId: MarkerId('dropOffid'),
    );

    setState(() {
      markers.add(picupLocationMarker);
      markers.add(dropOffLocationMarker);
    });

    Circle pickUpCircle = Circle(
        fillColor: Colors.blue,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
        circleId: CircleId('pickUpId'));

    Circle dropOffCircle = Circle(
        fillColor: Colors.red,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.red,
        circleId: CircleId('DropOffId'));

    setState(() {
      circles.add(pickUpCircle);
      circles.add(dropOffCircle);
    });
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchCotainerHeight = 0.0;
      rideDetailsContainerHeight = 200.0;
      bottomPaddingOfMap = 250;
      drawerOpen = false;
    });
  }

  void resetApp() {
    setState(() {
      drawerOpen = true;
      searchCotainerHeight = 250.0;
      rideDetailsContainerHeight = 0.0;
      requestRideContainerHeight = 0.0;
      polylineSet.clear();
      markers.clear();
      circles.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingOfMap = 250.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  void saveRideRequest() {
    rideRequestreference =
        FirebaseDatabase.instance.reference().child('ride request').push();
    var pickUp =
        Provider.of<AppData>(context, listen: false).userPickupLocation;
    var dropOff =
        Provider.of<AppData>(context, listen: false).userDropoffLocation;
    Map pickUpMap = {
      'latitude': pickUp.latitude.toString(),
      'longitude': pickUp.longitude.toString(),
    };
    Map dropOffMap = {
      'latitude': dropOff.latitude.toString(),
      'longitude': dropOff.longitude.toString()
    };
    Map rideInfoMap = {
      'driver_id': 'waiting',
      'payment_method': 'cach',
      'pickup': pickUpMap,
      'dropoff': dropOffMap,
      'created_at': DateTime.now().toString(),
      'rider_name': userCurrentInfo.name,
      'rider_phone': userCurrentInfo.phone,
      'pickup_address': pickUp.placeName,
      'dropoff_address': dropOff.placeName
    };
    rideRequestreference.set(rideInfoMap);
  }

  void cancelRideRequest() {
    rideRequestreference.remove();
  }
}
