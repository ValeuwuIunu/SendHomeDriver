import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sendhomedriver/global/global.dart';
import 'package:sendhomedriver/pushNotification/push_notification_system.dart';

import '../Assistants/assistant_methods.dart';
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) :super(key:key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController>_controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(4.6405666, -74.0731234),
      zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOffMap = 50;

  List<LatLng> plineCoordinatedList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker>markerSet ={};
  Set<Circle>circleSet ={};

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  checkIfLocationPermissonAllowed()async {
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async{
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;
    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 15);


    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanRedableAdress = await AssistanMethods.searchAddressForGeographicCoordinate(driverCurrentPosition!, context);
    print("This is our addres = " + humanRedableAdress );


    AssistanMethods.readDriverRatings(context);


  }

  readCurrentDriverInformation()async{
    currentUser=firebaseAuth.currentUser;
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentUser!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value !=null){
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email= (snap.snapshot.value as Map)["email"];
        onlineDriverData.licencia = (snap.snapshot.value as Map)["licencia"];
        onlineDriverData.rating = (snap.snapshot.value as Map)["raitings"];
        onlineDriverData.car_placa = (snap.snapshot.value as Map)["car_details"]["car_placa"];
        onlineDriverData.car_color = (snap.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriverData.car_model = (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_capacity = (snap.snapshot.value as Map)["car_details"]["car_capacity"];
        onlineDriverData.car_Type = (snap.snapshot.value as Map)["car_details"]["Tamaño Camion"];
        driverVehicleType =(snap.snapshot.value as Map)["car_details"]["Tamaño Camion"];
      }
    });

    AssistanMethods.readDriverEarnings(context);
  }
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkIfLocationPermissonAllowed();
    readCurrentDriverInformation();
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
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

            locateDriverPosition();
          },
        ),
        //ui for online/offline driver
        statusText !="Now Online" ?
            Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Colors.black87,
            ):Container(),
        
        //buton for online/offline driver 
        Positioned(
          top: statusText != "Now Online" ? MediaQuery.of(context).size.height * 0.45:40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: (){
                    if(isDriverActive != true){
                      driverisOnlineNow();
                      updateDriversLocationAtRealTime();

                      setState(() {
                        statusText = "Now Online";
                        isDriverActive=true;
                        buttonColor=Colors.transparent;
                      });
                    }else{
                      driverIsOfflineNow();
                      setState(() {
                        statusText="Now Offline";
                        isDriverActive= false;
                        buttonColor=Colors.grey;
                      });
                      Fluttertoast.showToast(msg: "You are offline now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    )
                  ),
                  child: statusText != "Now Online" ? Text(statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                  ) : Icon(
                    Icons.phonelink_ring,
                    color: Colors.white,
                  ),
              )
            ],
          ),
        )

      ],
    );
  }


  driverisOnlineNow() async{
    Position pos =await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    driverCurrentPosition = pos;

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");
    
    ref.set("idle");
    ref.onValue.listen((event) { });
  }

  updateDriversLocationAtRealTime(){

    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      if(isDriverActive == true){
        Geofire.setLocation(currentUser!.uid,driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow(){
    
    Geofire.removeLocation(currentUser!.uid);
    
    DatabaseReference? ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");
    
    ref.onDisconnect();
    ref.remove();
    ref = null;
    
    Future.delayed(Duration(milliseconds: 2000),(){
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
    
    
  }


}
    