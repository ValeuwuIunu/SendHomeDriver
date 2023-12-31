import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sendhomedriver/Assistants/assistant_methods.dart';
import 'package:sendhomedriver/global/global.dart';
import 'package:sendhomedriver/models/user_ride_request_information.dart';

import '../Screens/new_trip_screen.dart';

class NotificationDialogBox extends StatefulWidget {
  //const NotificationDialogBox({super.key});

  UserRideRequestInformation? userRideRequestInformation;

  NotificationDialogBox({this.userRideRequestInformation});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
                onlineDriverData.car_Type =="Pequeño"? "assets/Pequeño.jpg"
                    : onlineDriverData.car_Type=="Mediano"? "assets/Mediano.jpg"
                    : "assets/Grande.jpg"
            ),
            SizedBox(height: 10,),
            
            Text("New Ride Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 14,),

            Divider(
              height: 2,
              thickness: 2,
              color: Colors.deepPurpleAccent,
            ),

            Padding(
                padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("assets/origen.png",
                      width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 10,),

                      Expanded(
                          child: Text(
                            widget.userRideRequestInformation!.originAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.deepPurpleAccent,
                            ),
                          )
                      )
                    ],
                  ),

                  SizedBox(height: 20,),


                  Row(
                    children: [
                      Image.asset("assets/destino.png",
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 10,),

                      Expanded(
                          child: Text(
                            widget.userRideRequestInformation!.destinationAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.deepPurpleAccent,
                            ),
                          )
                      )
                    ],
                  ),


                ],
              ),
            ),

            Divider(
              height: 2,
              thickness: 2,
              color:Colors.deepPurpleAccent
            ),

            Padding(
                padding:EdgeInsets.all(20),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer=AssetsAudioPlayer();

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red
                      ),
                      child: Text(
                        "Cancelar".toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      )
                  ),

                  SizedBox(width: 20,),

                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer=AssetsAudioPlayer();

                        acceptRideRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green
                      ),
                      child: Text(
                        "Aceptar".toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      )
                  )

                ],
              )
            )
          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context){
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {

          if(snap.snapshot.value =="idle"){
            FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("newRideStatus").set("accepted");


            AssistanMethods.pauseLiveLocationUpdate();


            //trip started now - send driver to new tripScreen

            Navigator.push(context, MaterialPageRoute(builder: (c)=>NewTripScreen(
              userRideRequestInformation: widget.userRideRequestInformation,
            )));
          }else{
            Fluttertoast.showToast(msg: "Este acarreo es inexistente");
          }

    });
  }

}
