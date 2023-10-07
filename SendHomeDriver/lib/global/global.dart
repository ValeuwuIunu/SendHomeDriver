import 'package:firebase_auth/firebase_auth.dart';


import '../models/direction_detail_info.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;


DirectionDetailsInfo? tripdirectionDetailsInfo;
String userDropOffAddress="";