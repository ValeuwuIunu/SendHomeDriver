import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sendhomedriver/Assistants/request_assistant.dart';


import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHadler/app_info.dart';
import '../models/direction_detail_info.dart';
import '../models/directions.dart';
import '../models/user_model.dart';

class AssistanMethods{
  
  static void readCurrendOnLineUserInfo() async{
    
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
    .ref()
    .child("users")
    .child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value !=null){
        userModelCurrentInfo =UserModel.fromSnapshot(snap.snapshot);
      }
    });

  }


  static Future<String> searchAddressForGeographicCoordinate(Position position,  context) async {
    String apiUrl = "https://maps.google.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if (requestResponse != "Error Occurred. Failed. No Response") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      // Aquí puedes usar Provider para actualizar la ubicación de recogida si es necesario.
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }else{
      print("Error");
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo>obtainOriginToDestinationDirectionDetails(LatLng originPosition,LatLng destinationposition)async{

    String urlOriginToDestinationDirectionDetails="https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationposition.latitude},${destinationposition.longitude}&key=$mapKey";


    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);
    //if(responseDirectionApi =="Error Ocurred.Failesd No Response"){
      //return;
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    print("Entre");
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text=responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value=responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text=responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value=responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    print(directionDetailsInfo.duration_text);
    print(directionDetailsInfo.duration_value);
    print(directionDetailsInfo.distance_text);
    print(directionDetailsInfo.distance_value);
    print("fin");
    return directionDetailsInfo;
  }


  static pauseLiveLocationUpdate(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  static double calculateFareAmountFromOrginToDestination(DirectionDetailsInfo directionDetailsInfo){
    print("por_Info");
    print(directionDetailsInfo.duration_value!);
    print(directionDetailsInfo.distance_value!);
    double timeTravelledFareAmountPerMinute = (directionDetailsInfo.duration_value! /60)*10;
    print("por_minuto");
    print(timeTravelledFareAmountPerMinute);
    double distanceTravelledFareAmountPerKilometer = (directionDetailsInfo.distance_value! /1000)*50;
    print("por_kilmetro");
    print(distanceTravelledFareAmountPerKilometer);
    double totalFareAmount = timeTravelledFareAmountPerMinute+distanceTravelledFareAmountPerKilometer;
    double localCurrencyTotalFare = totalFareAmount;


    if(driverVehicleType =="Pequeño"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate())*0.8);
      print("C-------");
      print(resultFareAmount);
      print("C-------");
      resultFareAmount;
    }
    else if(driverVehicleType =="Mediano"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate())*1.5);
      print("C-------");
      print(resultFareAmount);
      print("C-------");
      resultFareAmount;
    }
    else if(driverVehicleType =="Grande"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate())*2);
      print("C-------");
      print(resultFareAmount);
      print("C-------");
      resultFareAmount;
    }
    else{
      return localCurrencyTotalFare.truncate().toDouble();
    }
    return localCurrencyTotalFare.truncate().toDouble();
  }



}