import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../global/global.dart';
import 'LoginScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final _correoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  void _submit(){
    firebaseAuth.sendPasswordResetEmail(
        email: _correoController.text.trim()
    ).then((value) {
      Fluttertoast.showToast(msg: "Te hemos enviado un correo para reestablecer tu contraseña");
    }).onError((error, stackTrace){
      Fluttertoast.showToast(msg: "Ha ocurrido un error: \n ${error.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/Frame_1.png'), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar( actions: [],
            toolbarHeight: 80,
            titleTextStyle: const TextStyle(
              fontSize: 28.0, // Tamaño de fuente
              fontWeight: FontWeight.bold, // Peso de fuente
              color: Colors.white, // Color del texto
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: SafeArea(
              child: Center(
                child: SingleChildScrollView(

                  child: SizedBox(
                    width: 400, // Ancho del Card
                    height: 300, // Alto del Card
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(child:
                          TextFormField(
                            controller: _correoController,
                            decoration: InputDecoration(
                              hintText: 'Correo electrónico',
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .blue), // Cambia el color del borde enfocado si es necesario
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54)),
                              prefixIcon: Icon(Icons.mail,color: Colors.deepPurpleAccent),
                            ),
                            cursorColor: Colors.blue,
                            autovalidateMode:AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if(value==null || value.isEmpty){
                                return "El Correo no puede estar vacio";
                              }
                              if(EmailValidator.validate(value)==true){
                                return null;
                              }
                              if(value.length <2){
                                return "Porfavor ingrese un Correo valido";
                              }
                              if(value.length >99){
                                return "El Correo no puede tener mas de 100 caracteres ";
                              }
                            },
                          ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              onPressed: () {
                                   _submit();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(47, 8, 73, 0.5),
                                foregroundColor:
                                Colors.white, // Color del texto del botón
                                elevation: 10, // Altura de la sombra
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 45.0,
                                    vertical: 10.0), // Relleno interno del botón
                              ),
                              child: Text(
                                'Restablecer Contraseña',
                                style: TextStyle(
                                    fontSize:
                                    18.0), // Tamaño de fuente del texto del botón
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){},
                            child:Center(
                              child: Text(
                                '¿Olvidó su contraseña?',
                                style: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "¿No tiene una cuenta?",
                                style: TextStyle(
                                  color:Colors.black45,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 40,),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));
                                },
                                child: Text(
                                  ' Ingresar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

