import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final nombreTextEditingController=TextEditingController();
  final celularTextEditingController=TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");

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
            icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
            ),
          ),
          title: Text("Pantalla de perfil",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle
                  ),
                  child:Icon(Icons.person,color: Colors.white,)
                ),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${userModelCurrentInfo!.nombre!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        onPressed: (){
                          showUserNameDialogAlerte(context, userModelCurrentInfo!.nombre!);
                        },
                        icon: Icon(Icons.edit,
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
                    Text("${userModelCurrentInfo!.celular!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        onPressed: (){
                          showUserCelularDialogAlerte(context, userModelCurrentInfo!.celular!);
                        },
                        icon: Icon(Icons.edit,
                        )
                    )
                  ],
                ),

                Divider(
                  thickness: 1,
                ),


                    Text("${userModelCurrentInfo!.correo!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),



              ],
            ),
          ),
        ),
      ),
    );
  }
}
