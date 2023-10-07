import 'package:flutter/cupertino.dart';

import '../models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;



  //List<String> historyTripsKeysList = [];
  //List<TripsHistoryModel>allTripsHistoryInformationList = [];


  void updatePickUpLocationAddress(Directions userPickUpAddres){
    userPickUpLocation = userPickUpAddres;
    notifyListeners();

  }

  void updateDropOffLocationAddres(Directions dropOffAddres){
    userDropOffLocation = dropOffAddres;
    notifyListeners();
  }
}