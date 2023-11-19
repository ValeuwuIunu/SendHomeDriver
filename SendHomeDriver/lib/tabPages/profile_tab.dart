import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sendhomedriver/global/global.dart';
import 'package:sendhomedriver/splashScreen/splash_screen.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {

  final nombreTextEditingController = TextEditingController();
  final celularTextEditingController=TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");

  Future<void>showUserNameDialogAlerte(BuildContext context,String name){

    nombreTextEditingController.text=name;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Guardar"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombreTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar",style: TextStyle(color: Colors.red),)
              ),
              TextButton(
                  onPressed: (){
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "name":nombreTextEditingController.text.trim(),
                    }).then((value){
                      nombreTextEditingController.clear();
                      Fluttertoast.showToast(msg: "actualización exitosa.\n Recarga la aplicación para ver el cambio");
                    }).catchError((errorMesage){
                      Fluttertoast.showToast(msg: "Ocurrio un error. \n $errorMesage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Ok",style: TextStyle(color: Colors.red),)
              )
            ],
          );
        }
    );
  }

  Future<void>showUserCelularDialogAlerte(BuildContext context,String phone){

    celularTextEditingController.text=phone;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Guardar"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: celularTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar",style: TextStyle(color: Colors.red),)
              ),
              TextButton(
                  onPressed: (){
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "phone":celularTextEditingController.text.trim(),
                    }).then((value){
                      celularTextEditingController.clear();
                      Fluttertoast.showToast(msg: "actualización exitosa.\n Recarga la aplicación para ver el cambio");
                    }).catchError((errorMesage){
                      Fluttertoast.showToast(msg: "Ocurrio un error. \n $errorMesage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Ok",style: TextStyle(color: Colors.red),)
              )
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){

        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios,color: Colors.black,
            ),
          ),
          title: Text("Profile Screen", style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person,color: Colors.white,),
                    ),

                    SizedBox(height: 30,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.name}",

                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        IconButton(
                            onPressed:(){
                              showUserNameDialogAlerte(context,onlineDriverData.name!);
                            },
                            icon: Icon(
                              Icons.edit,
                              color:Colors.deepPurpleAccent,
                            )
                        )
                      ],
                    ),

                    Divider(
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData!.phone!}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                            onPressed: (){
                              showUserCelularDialogAlerte(context, onlineDriverData!.phone!);
                            },
                            icon: Icon(
                              Icons.edit,
                              color:Colors.deepPurpleAccent,
                            )
                        )
                      ],
                    ),

                    Divider(
                      thickness: 1,
                    ),


                    Text("${onlineDriverData!.email!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),

                    ),
                    SizedBox(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.car_model!}\n ${onlineDriverData!.car_color} (${onlineDriverData!.car_placa!})",
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        ),

                        Image.asset(
                            onlineDriverData.car_Type =="Pequeño"? "assets/Pequeño.jpg"
                                : onlineDriverData.car_Type=="Mediano"? "assets/Mediano.jpg"
                                : "assets/Grande.jpg",
                                scale:2,
                        ),
                      ],
                    ),

                    SizedBox(height: 20,),
                    ElevatedButton(
                        onPressed: (){
                          firebaseAuth.signOut();
                          Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.redAccent,
                        ),
                        child: Text("Log Out")),
                  ],
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}
