import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sendhomedriver/global/global.dart';
import 'package:sendhomedriver/models/user_ride_request_information.dart';

import 'notification_dialog_box.dart';

class PushNotificationSystem{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async{
    //1.Teminated
    //When the app is closed and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if(remoteMessage != null){
        readUserRideRequestInformation(remoteMessage.data["rideRequestId"],context);
      }
    });
    
    //2. Foreground
    //When the app is open and receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"],context);
    });

    //3 Background
    //When the app is in background and opened directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {

      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"],context);

    });
  }
  readUserRideRequestInformation(String userRideRequestId,BuildContext  context){
    FirebaseDatabase.instance.ref().child("All Ride Request").child(userRideRequestId).child("driverId").onValue.listen((event) {
      if(event.snapshot.value == "waiting" || event.snapshot.value == firebaseAuth.currentUser!.uid){
        FirebaseDatabase.instance.ref().child("All Ride Request").child(userRideRequestId).once().then((snapData) {
          if(snapData.snapshot.value!= null){

            audioPlayer.open(Audio("musica/SD_ALERT_29.mp3"));
            audioPlayer.play();

            double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["Latitude"]);
            double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["Longitude"]);
            String originAddress =(snapData.snapshot.value! as Map)["originAddress"];


            double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["Latitude"]);
            double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["Longitude"]);
            String destinationAddress =(snapData.snapshot.value! as Map)["destinationAddress"];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

            String? rideRequestId = snapData.snapshot.key;


            UserRideRequestInformation userRideRequestInformation= UserRideRequestInformation();
            userRideRequestInformation.originLatLng = LatLng(originLat, originLng);
            userRideRequestInformation.originAddress=originAddress;
            userRideRequestInformation.destinationLatLng=LatLng(destinationLat, destinationLng);
            userRideRequestInformation.destinationAddress=destinationAddress;
            userRideRequestInformation.userName=userName;
            userRideRequestInformation.userPhone=userPhone;
            userRideRequestInformation.rideRequestId=rideRequestId;

            showDialog(
                context: context,
                builder: (BuildContext context) => NotificationDialogBox()
            );
          }
          else{
            Fluttertoast.showToast(msg: "This Ride Request Id do not exists");
          }
        });
      }
      else{
        Fluttertoast.showToast(msg: "This Ride Request has been cacelled");
        Navigator.pop(context);
      }
    });
  }

  Future generateAndGetToken() async{
    String? registrationToken = await messaging.getToken();
    print("FCM registration Token: ${registrationToken}");
    
    FirebaseDatabase.instance.ref()
    .child("drivers")
    .child(firebaseAuth.currentUser!.uid)
    .child("token")
    .set(registrationToken);
    
    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
    
  }


}