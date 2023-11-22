import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendhomedriver/infoHadler/app_info.dart';

import '../widgets/history_design_ui.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Historial de acarreos ",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close,color:Colors.black),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(

        padding: EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context,i){
              return Card(
                color: Colors.grey[100],
                shadowColor: Colors.transparent,
                child: HistoryDesignUIWidget(
                  tripsHistoryModel: Provider.of<AppInfo>(context,listen: false).allTripsHistoryInformationList[i],
                ),
              );
            },
            separatorBuilder: (context,i) => SizedBox(height: 30,),
            itemCount: Provider.of<AppInfo>(context,listen: false).allTripsHistoryInformationList.length,
        ),
      ),
    );
  }
}
