import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sendhomedriver/models/driver_data.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import '../models/direction_detail_info.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

UserModel? userModelCurrentInfo;

Position? driverCurrentPosition;


DriverData  onlineDriverData = DriverData();
String titleStarsRating ="";

String? driverVehicleType = "";
