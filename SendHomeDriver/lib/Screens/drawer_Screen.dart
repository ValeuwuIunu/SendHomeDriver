import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sendhomedriver/Screens/profile_screen.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';


class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
        child: Drawer(
          child: Padding(
            padding: EdgeInsets.fromLTRB(30, 50, 0, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          shape: BoxShape.circle
                        ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 20,),
                    Text(
                        userModelCurrentInfo!.nombre!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                    ),
                    SizedBox(height: 20,),

                    GestureDetector(
                      onTap: (){

                        Navigator.push(context, MaterialPageRoute(builder: (c)=>ProfileScreen()));
                      },
                      child: Text(
                        "Editar Perfil",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.deepPurpleAccent
                        ),
                      ),
                    ),

                    SizedBox(height: 30,),

                    Text("Tus viajes",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

                    SizedBox(height: 30,),

                    Text("Pagos",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

                    SizedBox(height: 30,),

                    Text("Notificaciones",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

                    SizedBox(height: 30,),

                    Text("Promociones",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

                    SizedBox(height: 30,),

                    Text("Ayuda",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

                    SizedBox(height: 30,),

                    Text("Viajes gratis",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

                    SizedBox(height: 15,),

                  ],
                ),

                GestureDetector(
                  onTap: (){
                    firebaseAuth.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
                  },
                  child: Text(
                    "Cerrar sesion",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
