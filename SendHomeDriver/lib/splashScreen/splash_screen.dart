import 'dart:async';
import 'package:flutter/material.dart';


import '../Assistants/assistant_methods.dart';
import '../Screens/LoginScreen.dart';
import '../Screens/Mapa_conductor.dart';
import '../global/global.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) :super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer(){
    Timer(Duration(seconds: 3), () async{
      if(await firebaseAuth.currentUser != null){
        firebaseAuth.currentUser != null? AssistanMethods.readCurrendOnLineUserInfo():null;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MapScreenDriver()));
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }
    });
  }

  @override
  void initState(){
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Send!',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
          ),
        ),
      ),
    );
  }
}
