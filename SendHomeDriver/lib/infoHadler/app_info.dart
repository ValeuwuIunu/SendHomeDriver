import 'package:flutter/cupertino.dart';

import '../models/directions.dart';
import '../models/trips_history_model.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  String driverTotalEarnings = "0";
  String driverAverageRatings = "0";


  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel>allTripsHistoryInformationList = [];


  void updatePickUpLocationAddress(Directions userPickUpAddres){
    userPickUpLocation = userPickUpAddres;
    notifyListeners();

  }

  void updateDropOffLocationAddres(Directions dropOffAddres){
    userDropOffLocation = dropOffAddres;
    notifyListeners();
  }


  updateOverAllTripsCounter(int overAllTripsCounter){
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripKeysList){

    historyTripsKeysList = tripKeysList;
    notifyListeners();

  }

  updateOverAllTripHistoryInformation(TripsHistoryModel eachTripHistory){
    allTripsHistoryInformationList.add(eachTripHistory);
    notifyListeners();

  }

  updateDriverTotalEarnings(String driverEarnings){

    driverTotalEarnings=driverEarnings;

  }

  updateDriverAverageRatings(String driverRatings){
    driverAverageRatings = driverRatings;
  }


}