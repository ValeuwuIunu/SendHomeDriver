import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sendhomedriver/Assistants/assistant_methods.dart';
import 'package:sendhomedriver/global/global.dart';
import 'package:sendhomedriver/models/user_ride_request_information.dart';
import 'package:sendhomedriver/splashScreen/splash_screen.dart';
import 'package:sendhomedriver/widgets/fare_amount_collection_dialog.dart';

import '../widgets/progres_dialog.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestInformation;

  NewTripScreen({
    this.userRideRequestInformation,
});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {

  GoogleMapController? newGoogleMapController;
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController>_controllerGoogleMap = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(4.6405666, -74.0731234),
    zoom: 14.4746,
  );

  String? buttonTitle = "Llegando";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMaker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;


  //Step 1: when driver accepts the user ride request
  //originLatLng = driverCurrent location
  //destinationLatLng = user Pickup location

  //step 2: when  driver picks up the user ride request
  //originLatLng = user current location which will be also  the current location of the driver al the tiem
  //destinationLatLng = user's drop-off location
  Future<void>drawPolylineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng,bool darkTheme) async{

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgresDialog(message: "Por favor, espera. . .",)
    );

    var directionDetailsInfo = await AssistanMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints  = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();

    if(decodePolyLinePointsResultList.isNotEmpty){
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
          color: darkTheme ? Colors.amber.shade400 : Colors.deepPurpleAccent,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude,destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude,originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude,originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude,destinationLatLng.longitude),
      );
    }
    else{
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
        markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
        markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
    );


    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
        circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });




  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();
  }

  getDriverLocationUpdatesAtRealTime(){


    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position ) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition  =position;

      LatLng latLngLiveDriverPosition = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);


      Marker animatinMarker = Marker(
          markerId: MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMaker!,
        infoWindow: InfoWindow(title: "Esta es tu ubicación")
      );
      
      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition,zoom: 18);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere((element) => element.markerId.value ==  "AnimatedMarker");

        setOfMarkers.add(animatinMarker);
      });


      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();
      
      //updating driver location at real time in database
      Map driverLatLngDataMap  = {
        "latitude" : onlineDriverCurrentPosition!.latitude.toString(),
        "longitude" : onlineDriverCurrentPosition!.longitude.toString(),
      };
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestInformation!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);
      
    });

  }

  updateDurationTimeAtRealTime() async{

    if(isRequestDirectionDetails == false){
      isRequestDirectionDetails = true;


      if(onlineDriverCurrentPosition == null){
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;

      if(rideRequestStatus == "acepted"){
        destinationLatLng = widget.userRideRequestInformation!.originLatLng;
      }
      else{
        destinationLatLng = widget.userRideRequestInformation!.destinationLatLng;
      }
      var directionInformation = await AssistanMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

      if(directionInformation != null){
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails = false;
    }

  }

  createDriverIconMarker(){
    if(iconAnimatedMaker == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context,size: Size(2,2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/Pequeño.jpg").then((value) {
        iconAnimatedMaker = value;
      });
    }
  }

  saveAssignedDriverDetailsToUserRideRequest(){
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestInformation!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude" : driverCurrentPosition!.latitude.toString(),
      "longitude" : driverCurrentPosition!.longitude.toString(),
    };

    if(databaseReference.child("driverId") != "waiting") {
      databaseReference.child("driverLocation").set(driverLocationDataMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);
      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      databaseReference.child("raitings").set(onlineDriverData.rating);
      databaseReference.child("car_details").set(onlineDriverData.car_model.toString() + " " + onlineDriverData.car_placa.toString() + " (" + onlineDriverData.car_color.toString() + ")");
      
      saveRideRequestIdToDriverHistory();
    }
    else{
      Fluttertoast.showToast(msg: "Este acarreo ha sido tomado por otro conductor. \n Recargando");
    Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
    }

  }

  saveRideRequestIdToDriverHistory(){
    DatabaseReference tripsHistoryRef  = FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("tripHistory");

    tripsHistoryRef.child(widget.userRideRequestInformation!.rideRequestId!).set(true);

    //fare amount
  }

  endTripNow() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext) => ProgresDialog(message: "Por favor espere...",)
    );

    var currentDriverPositionLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

    var tripDirectionDetails = await AssistanMethods.obtainOriginToDestinationDirectionDetails(currentDriverPositionLatLng, widget.userRideRequestInformation!.originLatLng!);

    //fare amount

    double totalFareAmount = AssistanMethods.calculateFareAmountFromOrginToDestination(tripDirectionDetails);
    print("-------");
    print(totalFareAmount);
    print("-------");
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestInformation!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());

    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestInformation!.rideRequestId!).child("status").set("ended");

    Navigator.pop(context);

    //display fare amount in dialog box
    showDialog(
        context: context,
        builder: (BuildContext context) => FareAmountCollectionDialog(
          totalFareAmount: totalFareAmount,
        )
    );

    //save fare aount to  driver total earnings
    saveFareAmountToDriverEarnings(totalFareAmount);
  }


  saveFareAmountToDriverEarnings(double totalFareAmount){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap) {
      if(snap.snapshot.value != null){
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount+oldEarnings;

        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(driverTotalEarnings.toString());
      }
      else{
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(totalFareAmount.toString());
      }
    });
  }

@override
  Widget build(BuildContext context) {

    createDriverIconMarker();

    bool darkTheme = MediaQuery.of(context).platformBrightness==Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);


              var userPickUpLatLng = widget.userRideRequestInformation!.originLatLng;

              drawPolylineFromOriginToDestination(driverCurrentLatLng,userPickUpLatLng!,darkTheme);

              getDriverLocationUpdatesAtRealTime();

            },
          ),
          Positioned(
            bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                         color: Colors.white,
                        blurRadius: 18,
                        spreadRadius: 0.5,
                        offset: Offset(0.6,0.6),
                      )
                    ]
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(durationFromOriginToDestination,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:Colors.black
                        ),
                        ),

                        SizedBox(height: 10,),
                        Divider(thickness: 1,color: Colors.grey,),

                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.userRideRequestInformation!.userName!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color:Colors.black,
                              ),
                            ),
                            IconButton(
                                onPressed: (){

                                },
                                icon: Icon(Icons.phone,color:Colors.black),
                            )
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset("assets/origen.png",
                            width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 10,),
                            Expanded(child:
                            Container(
                              child: Text(
                                widget.userRideRequestInformation!.originAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black
                                ),
                              ),
                            )
                            )
                          ],
                        ),
                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset("assets/destino.png",
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 10,),
                            Expanded(child:
                            Container(
                              child: Text(
                                widget.userRideRequestInformation!.destinationAddress!,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black
                                ),
                              ),
                            )
                            )
                          ],
                        ),

                        SizedBox(height: 10,),
                        Divider(
                          thickness: 1,
                          color:Colors.grey
                        ),
                        
                        SizedBox(height: 10,),
                        ElevatedButton.icon(
                            onPressed: () async{
                              if(rideRequestStatus =="accepted"){
                                rideRequestStatus = "arrived";
                                FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestInformation!.rideRequestId!).child("status").set(rideRequestStatus);

                                setState(() {
                                  buttonTitle = "Vamos";
                                  buttonColor = Colors.lightGreen;
                                });

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>  ProgresDialog(message: "Cargando...",)
                                );

                                await drawPolylineFromOriginToDestination(
                                    widget.userRideRequestInformation!.originLatLng!,
                                    widget.userRideRequestInformation!.destinationLatLng!,
                                    darkTheme
                                );


                                Navigator.pop(context);
                              }
                              //[user has been picked from the user's current location] - Let's Go Button
                              else if(rideRequestStatus=="arrived"){
                                rideRequestStatus ="ontrip";

                                FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestInformation!.rideRequestId!).child("status").set(rideRequestStatus);

                                setState(() {
                                  buttonTitle = "Finalizar acarreo";
                                  buttonColor = Colors.red;
                                });
                              }
                              //[user/driver has reached the drop-off location] - End Trip Button
                              else if (rideRequestStatus == "ontrip"){
                                endTripNow();
                              }
                            },
                            icon: Icon(Icons.directions_car,color: Colors.white,size: 25,),
                            label: Text(
                              buttonTitle!,
                              style: TextStyle(
                                color:Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                        ),

                      ],
                    ),
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
}
