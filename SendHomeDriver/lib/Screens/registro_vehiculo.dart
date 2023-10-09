import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sendhomedriver/Screens/registro_conductor.dart';
import '../global/global.dart';
import '../select_imagen.dart';
import 'LoginScreen.dart';




class RegistrationVehiculoPage extends StatefulWidget {
  @override
  _RegistrationVehiculoPageState createState() =>
      _RegistrationVehiculoPageState();
}

class _RegistrationVehiculoPageState extends State<RegistrationVehiculoPage> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _colorController = TextEditingController();
  final _capacidadController = TextEditingController();

  bool selectedTypeAceptar = false;


  _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Sube la imagen del carro a Firebase Storage
        String carImageStoragePath = 'cars/${currentUser!.uid}/car_image.jpg';
        final carImageRef = FirebaseStorage.instance.ref().child(carImageStoragePath);
        await carImageRef.putFile(Foto_Carro!);

        // Sube la imagen del documento de propiedad a Firebase Storage
        String documentImageStoragePath = 'cars/${currentUser!.uid}/document_image.jpg';
        final documentImageRef = FirebaseStorage.instance.ref().child(documentImageStoragePath);
        await documentImageRef.putFile(Foto_Documento_propiedad!);

        // Guarda los detalles del vehículo en Firebase Realtime Database
        Map driverCarInfoMap = {
          "id": currentUser!.uid,
          "car_placa": _placaController.text.trim(),
          "car_model": _modeloController.text.trim(),
          "car_color": _colorController.text.trim(),
          "car_capacity": _capacidadController.text.trim(),
          "car_image": carImageStoragePath, // Almacena la referencia a la imagen en Storage
          "document_image": documentImageStoragePath, // Almacena la referencia a la imagen en Storage
        };

        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
        userRef.child(currentUser!.uid).child("car_details").set(driverCarInfoMap);

        Fluttertoast.showToast(msg: "Car details have been saved. Congratulations");
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      } catch (e) {
        Fluttertoast.showToast(msg: "Error occurred: \n $e");
      }
    }
  }
  File? Foto_Documento_propiedad;
  File? Foto_Carro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(204, 200, 236, 1.0),
      appBar: AppBar(
        leading: IconButton(
          icon:
          Icon(Icons.arrow_back_outlined, size: 30, color: Colors.black87),
          constraints: BoxConstraints.tightFor(width: 60, height: 60),
          highlightColor: Colors.cyan,
          splashColor: Colors.deepPurpleAccent,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => RegistrationConductorPage()));
          },
        ),
        toolbarHeight: 35,
        titleTextStyle: const TextStyle(
          fontSize: 28.0, // Tamaño de fuente
          fontWeight: FontWeight.bold, // Peso de fuente
          color: Colors.white, // Color del texto
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: ListView(
          children: [
         Container(
        padding: EdgeInsets.all(17.5),
        child: Card(
            color: Color.fromRGBO(185, 175, 224, 1.0), // Cambia el color de fondo
            elevation: 6.0, // Cambia la elevación y la sombra
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(12.0), // Cambia el radio de los bordes
            ),
            child: Container(
              height: 1120,
              width: 100,
              margin: EdgeInsets.all(15.5),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Agregar vehículo",
                            style: TextStyle(
                              color: Color.fromRGBO(47, 8, 73, 0.5),
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center, // Añade esta línea
                          ),
                          InkWell(
                            onTap: () async {
                              final imagen = await getImagen();
                              setState(() {
                                Foto_Carro = File(imagen!.path);
                              });
                            },
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Color.fromRGBO(47, 8, 73, 0.5),
                              child: Foto_Carro != null
                                  ? ClipOval(
                                child: Image.file(
                                  Foto_Carro!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            controller: _placaController,
                            decoration: InputDecoration(
                              hintText: 'Placa del vehículo',
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54)),
                              prefixIcon: Icon(Icons.airport_shuttle, color: Color.fromRGBO(47, 8, 73, 0.5)),
                            ),
                            cursorColor: Colors.deepPurpleAccent,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "La palca no puede estar vacía";
                              }
                              if (value.length < 2) {
                                return "Por favor ingrese una placa válida";
                              }
                              if (value.length > 6) {
                                return "La palca no puede tener más de 6 caracteres ";
                              }
                            },
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            controller: _modeloController,
                            decoration: InputDecoration(
                              hintText: 'Modelo del vehículo',
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54)),
                              prefixIcon: Icon(Icons.airport_shuttle, color: Color.fromRGBO(47, 8, 73, 0.5)),
                            ),
                            cursorColor: Colors.deepPurpleAccent,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "El modelo no puede estar vacío";
                              }
                              if (value.length < 2) {
                                return "Por favor ingrese un modelo válido";
                              }
                              if (value.length > 49) {
                                return "El modelo no puede tener más de 50 caracteres ";
                              }
                            },
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            controller: _colorController,
                            decoration: InputDecoration(
                              hintText: 'Color del vehículo',
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54)),
                              prefixIcon: Icon(Icons.format_color_fill, color: Color.fromRGBO(47, 8, 73, 0.5)),
                            ),
                            cursorColor: Colors.deepPurpleAccent,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "El color no puede estar vacío";
                              }
                              if (value.length < 2) {
                                return "Por favor ingrese un color válido";
                              }
                              if (value.length > 49) {
                                return "El color no puede tener más de 50 caracteres ";
                              }
                            },
                          ),
                          SizedBox(height: 30.0),
                          TextFormField(
                            controller: _capacidadController,
                            decoration: InputDecoration(
                              hintText: 'Capacidad del vehículo en Kg',
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54)),
                              prefixIcon: Icon(Icons.reduce_capacity, color:Color.fromRGBO(47, 8, 73, 0.5)),
                            ),
                            cursorColor: Colors.deepPurpleAccent,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "La capacidad no puede estar vacía";
                              }
                              final doubleParsed = double.tryParse(value);
                              if (doubleParsed == null) {
                                return "Por favor ingrese una capacidad válida";
                              }
                              if (doubleParsed > 500.0) {
                                return "La capacidad no puede ser mayor que 500";
                              }
                            },
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            "Agregar imagen de documento de propiedad ",
                            style: TextStyle(
                              color: Color.fromRGBO(47, 8, 73, 0.5),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          InkWell(
                            onTap: () async {
                              final imagen = await getImagen();
                              setState(() {
                                Foto_Documento_propiedad = File(imagen!.path);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              height: 200,
                              width: 400,
                              color:Color.fromRGBO(47, 8, 73, 0.5),
                              child: Foto_Documento_propiedad != null
                                  ? Image.file(
                                Foto_Documento_propiedad!,
                                width: 500,
                                height: 500,
                                fit: BoxFit.contain,
                              )
                                  : Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Color.fromRGBO(47, 8, 73, 0.5),
                                foregroundColor:
                                Colors.white, // Color del texto del botón
                                elevation: 10, // Altura de la sombra
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 45.0, vertical: 10.0),
                              ),
                              onPressed: () {
                                // Navegar a la siguiente pantalla o realizar otras acciones
                                _submit();
                              },
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(
                                    fontSize:
                                    18.0), // Tamaño de fuente del texto del botón
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            )),
            ),
          ],
      ),
    );
  }
}