import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendhomedriver/infoHadler/app_info.dart';

import '../Screens/trip_historyscreen.dart';
import '../global/global.dart';
class EarningsTapPage extends StatefulWidget {
  const EarningsTapPage({super.key});

  @override
  State<EarningsTapPage> createState() => _EarningsTapPageState();
}

class _EarningsTapPageState extends State<EarningsTapPage> {


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: Colors.deepPurpleAccent,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text(
                    "your Earnings:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                    ),
                  ),

                  const SizedBox(height: 10,),
                  
                  
                  Text("" + Provider.of<AppInfo>(context,listen: false).driverTotalEarnings,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Total Number Trips
          ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c) => TripHistoryScreen()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white54
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: Row(
                  children: [
                    Image.asset(
                        onlineDriverData.car_Type =="Pequeño"? "assets/Pequeño.jpg"
                            : onlineDriverData.car_Type=="Mediano"? "assets/Mediano.jpg"
                            : "assets/Grande.jpg",
                      scale: 2,
                    ),
                    SizedBox(width: 10,),

                    Text("Trips Completed",
                    style:TextStyle(color: Colors.white),
                    ),

                    Expanded(
                        child:
                    Container(
                      child: Text(
                        Provider.of<AppInfo>(context,listen: false).allTripsHistoryInformationList.length.toString(),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ))
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}
