import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendhomedriver/infoHadler/app_info.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../global/global.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({super.key});

  @override
  State<RatingsTabPage> createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {

  double ratingNumber = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getRatingsNumber(){
    setState(() {
      ratingNumber= double.parse(Provider.of(context,listen: false).driverAverageRatings);
    });

    setupRatingsTitle();
  }
  setupRatingsTitle(){
    if(ratingNumber ==1){
      setState(() {
        titleStarsRating="Very Bad";
      });
    }
    if(ratingNumber ==2){
      setState(() {
        titleStarsRating="Bad";
      });
    }
    if(ratingNumber ==3){
      setState(() {
        titleStarsRating="Good";
      });
    }
    if(ratingNumber ==4){
      setState(() {
        titleStarsRating="Very Good";
      });
    }
    if(ratingNumber ==5){
      setState(() {
        titleStarsRating="Exellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Container(
          margin: EdgeInsets.all(4),
            width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(

            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22.0,),
              Text(

                "Your Ratings",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent
                ),
              ),
              SizedBox(height: 20,),

              SmoothStarRating(
                rating: ratingNumber,
                allowHalfRating: true,
                starCount: 5,
                color: Colors.deepPurpleAccent,
                borderColor: Colors.deepPurpleAccent,
                size: 46,
              ),

              SizedBox(height: 12,),
              Text(
                titleStarsRating,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent
                ),
              ),
              SizedBox(height: 18,),
            ],
          ),
        ),
      ),
    );
  }
}
