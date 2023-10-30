import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sendhomedriver/models/driver_data.dart';


import '../models/direction_detail_info.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

UserModel? userModelCurrentInfo;

Position? driverCurrentPosition;


DriverData  onlineDriverData = DriverData();


String? driverVehicleType = "";
