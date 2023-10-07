import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc ;
import 'package:provider/provider.dart';
import 'package:sendhomedriver/Screens/precise_pickup_location.dart';
import 'package:sendhomedriver/Screens/search_place_screen.dart';


import '../Assistants/assistant_methods.dart';
import '../global/global.dart';
import '../infoHadler/app_info.dart';
import '../models/directions.dart';
import '../widgets/progres_dialog.dart';
import 'drawer_Screen.dart';


class MyMapScreen extends StatefulWidget {
  const MyMapScreen({Key? key}) : super(key: key);
  @override
 State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {

  LatLng? pickLocation;
  loc.Location location =loc.Location();
  String? _addres;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldstate = GlobalKey<ScaffoldState>();


  double searchLocationContainerHeight =200;
  double waitinResponsefromDrivercomtainerHeigth = 0;
  double assigneddriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOffMap = 50;

  List<LatLng> plineCoordinatedList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker>markerSet ={};
  Set<Circle>circleSet ={};

  String userName="";
  String userEmail="";

  bool openNavigationDrawer =true;
  bool activeNearbyDriverKeysLoaded = true;
  BitmapDescriptor? activeNearbyIcon;


  locateUserPosition() async{
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 15);
    
    
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanRedableAdress = await AssistanMethods.searchAddressForGeographicCoordinate(userCurrentPosition!, context);
    print("This is our addres = " + humanRedableAdress );

    userName=userModelCurrentInfo!.nombre!;
    userEmail=userModelCurrentInfo!.correo!;

    //initializeGeoFireListener();
    //AssistanMethods.readTripsKeysForOnlinerUser(context);

  }

  Future<void>drawPolyLineFromOriginToDestination() async{
    var originPosition  = Provider.of<AppInfo>(context,listen: false).userPickUpLocation;
    var destinationPosition  = Provider.of<AppInfo>(context,listen: false).userDropOffLocation;

    var originLatLng =LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng =LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) =>ProgresDialog(message: "Please wait",)
    );

    var directionDetailsInfo = await AssistanMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripdirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints points = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList = points.decodePolyline(directionDetailsInfo.e_points!);
    
    plineCoordinatedList.clear();
    
    if(decodePolyLinePointsResultList.isNotEmpty){
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        plineCoordinatedList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.deepPurpleAccent,
        polylineId: PolylineId("PolylineId"),
        jointType: JointType.round,
        points: plineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5
      );

      polylineSet.add(polyline);
    });
    LatLngBounds boundslatlang;
    if(originLatLng.latitude >destinationLatLng.latitude && originLatLng.longitude>destinationLatLng.longitude){
      boundslatlang=LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude >destinationLatLng.longitude){
      boundslatlang = LatLngBounds(
          southwest: LatLng(originLatLng.latitude,destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude,originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude>destinationLatLng.latitude){
      boundslatlang = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude,originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude,destinationLatLng.longitude),
      );
    }
    else{
      boundslatlang =LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }
    
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundslatlang, 65));

    Marker originMarker = Marker(
        markerId: MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName,snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName,snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
        circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng
    );

    Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatLng
    );
    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });


  }
  
  /*getAddressFromLatLng()async{
    try{
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: mapKey
      );
      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickLocation!.latitude;
        userPickUpAddress.locationLongitude = pickLocation!.longitude;
        userPickUpAddress.locationName = data.address;
        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
        //_addres = data.address;
      });
    }catch(exe){
      print(exe);
    }
  }*/

  checkIfLocationPermissonAllowed()async {
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void initState(){
    super.initState();
    checkIfLocationPermissonAllowed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key:_scaffoldstate,
        drawer: DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 40,bottom: bottomPaddingOffMap),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller){
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {

                });

                locateUserPosition();
              },
             /* onCameraMove: (CameraPosition? position){
                if(pickLocation !=position!.target){
                  setState(() {
                    pickLocation=position.target;
                  });
                }
              },
              onCameraIdle: (){
                getAddressFromLatLng();
;              },*/
            ),
            /*Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset('assets/position.png',height: 45,width: 45,),
              ),
            ),*/


            //custom Hamburger button for drawer
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                child: GestureDetector(
                  onTap: (){
                    _scaffoldstate.currentState!.openDrawer();
                  },
                  child:CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.menu,
                      color: Colors.deepPurpleAccent ,
                    ),
                  ) ,
                ),
              ),
            ),

           //ui for searching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined ,color : Colors.deepPurpleAccent),
                                      SizedBox(width:10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("From",
                                            style: TextStyle(
                                              color: Colors.deepPurpleAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(Provider.of<AppInfo>(context).userPickUpLocation !=null
                                              ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24)+"...":
                                              "Not get adresss",
                                            style: TextStyle(color: Colors.grey,fontSize: 14),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                SizedBox(height: 5,),
                                Padding(
                                    padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async{
                                      //go to search place screen
                                      var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=>SearchPlaceScreen()));

                                      if(responseFromSearchScreen == "obtainDropoff"){
                                        setState(() {
                                          openNavigationDrawer=false;
                                        });
                                      }
                                      await drawPolyLineFromOriginToDestination();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined ,color : Colors.deepPurpleAccent),
                                        SizedBox(width:10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("To",
                                              style: TextStyle(
                                                color: Colors.deepPurpleAccent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(Provider.of<AppInfo>(context).userDropOffLocation !=null
                                                ?Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                            :"where to?",
                                              style: TextStyle(color: Colors.grey,fontSize: 14),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          SizedBox(height: 5,),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (c)=>PrecisePickUpScreen()));
                                  },
                                  child: Text(
                                    "ChangePick Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.deepPurpleAccent,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )

                                  ),
                              ),

                              SizedBox(width: 10,),

                              ElevatedButton(
                                onPressed: (){

                                },
                                child: Text(
                                  "Request a ride",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.deepPurpleAccent,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )

                                ),
                              ),
                            ],
                          )

                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
           
           
           /* Positioned(
              top: 40,
              right: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurpleAccent),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  Provider.of<AppInfo>(context).userPickUpLocation !=null
                      ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24)+"...":"Not get adresss",
                  overflow:TextOverflow.visible,softWrap:true,
                ),
                ),
              ),*/


          ],
        ),
      ),
    );
  }
}