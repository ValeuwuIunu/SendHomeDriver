import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../Assistants/request_assistant.dart';
import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHadler/app_info.dart';
import '../models/directions.dart';
import '../models/predicted_place.dart';
import 'progres_dialog.dart';


class PlacePredictionTileDesign extends StatefulWidget {
  //const PlacePredictionTileDesign({Key? key}): super(key:key);

  final Predictedplaces? predictedPlaces;


  PlacePredictionTileDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {

  getPlaceDirectionDetails(String? placeId,context)async{

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgresDialog(
          message: "Seting up Drop-off. Plase wait..... ",
        )
    );
    String placeDirectionDetailUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailUrl);

    Navigator.pop(context);

    if(responseApi =="Error Ocurred.Failesd No Response"){
      return;
    }

    if(responseApi["status"]=="OK"){
      Directions directions = Directions();
      directions.locationName=responseApi["result"]["name"];
      directions.locationId=placeId;
      directions.locationLatitude =responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context,listen: false).updateDropOffLocationAddres(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });
      
      Navigator.pop(context,"obtaineDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed:(){
          getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
        ),
        child:Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location,
                color: Colors.deepPurpleAccent,
              ),
              SizedBox(width: 10,),

              Expanded(
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictedPlaces!.main_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),

                      Text(
                        widget.predictedPlaces!.secondary_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        )
    );
  }
}

