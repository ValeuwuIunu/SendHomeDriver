import 'package:flutter/material.dart';

class ProgresDialog extends StatelessWidget {
  //const ProgresDialog({Key? key}) :super(key: key);

  String? message;
  ProgresDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black45,
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            SizedBox(width: 6,),

            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),

            SizedBox(width: 26,),

            Text(
              message!,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12
              ),
            ),
          ],
        ),
      ),
    );
  }
}
