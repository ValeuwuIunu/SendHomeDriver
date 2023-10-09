import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sendhomedriver/Screens/registro_vehiculo.dart';
import '../global/global.dart';
import '../select_imagen.dart';
import 'LoginScreen.dart';

class RegistrationConductorPage extends StatefulWidget {
  const RegistrationConductorPage({Key? key}) : super(key: key);

  @override
  _RegistrationConductorPageState createState() =>
      _RegistrationConductorPageState();
}

class _RegistrationConductorPageState extends State<RegistrationConductorPage> {
  final _formKey = GlobalKey<FormState>();
  final _numUserController = TextEditingController();
  final _nombreUserController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordUserController = TextEditingController();
  final _passwordCUserController = TextEditingController();

  List<String> carTypes = ["C1", "C2", "C3"];
  String? selectedCarType;
  bool _passwordVisible = false;

  void _sumit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await firebaseAuth
            .createUserWithEmailAndPassword(
          email: _correoController.text.trim(),
          password: _passwordUserController.text.trim(),
        )
            .then((value) async {
          currentUser = value.user;
          if (currentUser != null) {
            // Sube la imagen de perfil a Firebase Storage
            String profileImagePath =
                'users/${currentUser!.uid}/profile_image.jpg';
            final profileImageRef =
            FirebaseStorage.instance.ref().child(profileImagePath);
            await profileImageRef.putFile(Foto_Perfil!);

            // Sube la imagen de licencia a Firebase Storage
            String licenseImagePath =
                'users/${currentUser!.uid}/license_image.jpg';
            final licenseImageRef =
            FirebaseStorage.instance.ref().child(licenseImagePath);
            await licenseImageRef.putFile(Foto_licencia!);

            Map userMap = {
              "id": currentUser!.uid,
              "Foto_licencia": licenseImagePath,
              "name": _nombreUserController.text.trim(),
              "email": _correoController.text.trim(),
              "phone": _numUserController.text.trim(),
              "licencia": selectedCarType,
              "Foto_Perfil": profileImagePath,
            };
            DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child("drivers");
            userRef.child(currentUser!.uid).set(userMap);
          }
          await Fluttertoast.showToast(msg: "Successfully Registered");
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => RegistrationVehiculoPage()));
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error occurred: \n $e");
      }
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  File? Foto_licencia;
  File? Foto_Perfil;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(204, 200, 236, 1.0),
      appBar: AppBar(
        toolbarHeight: 40,
        titleTextStyle: const TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(17.5),
            child: Card(
              color: Color.fromRGBO(185, 175, 224, 1.0),
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                height: 1250,
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
                      InkWell(
                        onTap: () async {
                          final imagen = await getImagen();
                          setState(() {
                            Foto_Perfil = File(imagen!.path);
                          });
                        },
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Color.fromRGBO(47, 8, 73, 0.9),
                          child: Foto_Perfil != null
                              ? ClipOval(
                            child: Image.file(
                              Foto_Perfil!,
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
                      SizedBox(height: 1),
                      IntlPhoneField(
                        showCountryFlag: false,
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Color.fromRGBO(47, 8, 73, 0.9),
                        ),
                        decoration: InputDecoration(
                          hintText: "Número",
                          hintStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        initialCountryCode: 'CC',
                        onChanged: (value) {
                          setState(() {
                            _numUserController.text = value.completeNumber;
                          });
                        },
                      ),
                      SizedBox(height: 1),
                      TextFormField(
                        controller: _nombreUserController,
                        decoration: InputDecoration(
                          hintText: 'Nombre completo',
                          labelStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurpleAccent),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          prefixIcon:
                          Icon(Icons.person, color: Color.fromRGBO(47, 8, 73, 0.9)),
                        ),
                        cursorColor: Colors.deepPurpleAccent,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "El nombre no puede estar vacío";
                          }
                          if (value.length < 2) {
                            return "Por favor ingrese un nombre válido";
                          }
                          if (value.length > 49) {
                            return "El nombre no puede tener más de 50 caracteres ";
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _correoController,
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          labelStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurpleAccent),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          prefixIcon:
                          Icon(Icons.mail, color: Color.fromRGBO(47, 8, 73, 0.9)),
                        ),
                        cursorColor: Colors.deepPurpleAccent,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "El Correo no puede estar vacío";
                          }
                          if (EmailValidator.validate(value) == true) {
                            return null;
                          }
                          if (value.length < 2) {
                            return "Por favor ingrese un Correo válido";
                          }
                          if (value.length > 99) {
                            return "El Correo no puede tener más de 100 caracteres ";
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          labelStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurpleAccent),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          prefixIcon:
                          Icon(Icons.password, color: Color.fromRGBO(47, 8, 73, 0.9)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color.fromRGBO(47, 8, 73, 0.9),
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        cursorColor: Colors.deepPurpleAccent,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "El Clave no puede estar vacío";
                          }
                          if (value.length < 2) {
                            return "Por favor ingrese una clave válida";
                          }
                          if (value.length > 99) {
                            return "La Clave no puede tener más de 100 caracteres ";
                          }
                        },
                        onChanged: (value) => setState(() {
                          _passwordUserController.text = value;
                        }),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Confirmar Contraseña',
                          labelStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurpleAccent),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          prefixIcon:
                          Icon(Icons.password, color: Color.fromRGBO(47, 8, 73, 0.9)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color.fromRGBO(47, 8, 73, 0.9),
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        cursorColor: Colors.deepPurpleAccent,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "El Clave no puede estar vacío";
                          }
                          if (value != _passwordUserController.text) {
                            return "El Password no coincide";
                          }
                          if (value.length < 2) {
                            return "Por favor ingrese una clave válida";
                          }
                          if (value.length > 99) {
                            return "La Clave no puede tener más de 100 caracteres ";
                          }
                        },
                        onChanged: (value) => setState(() {
                          _passwordCUserController.text = value;
                        }),
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        "Agregar imagen de licencia ",
                        style: TextStyle(
                          color: Color.fromRGBO(47, 8, 73, 0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      InkWell(
                        onTap: () async {
                          final imagen = await getImagen();
                          setState(() {
                            Foto_licencia = File(imagen!.path);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          height: 200,
                          width: 200,
                          color: Color.fromRGBO(47, 8, 73, 0.9),
                          child: Foto_licencia != null
                              ? Image.file(
                            Foto_licencia!,
                            width: 500,
                            height: 300,
                            fit: BoxFit.contain,
                          )
                              : Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                            hintText: "Categoria de licencia",
                            prefix:
                            Icon(Icons.car_crash, color: Color.fromRGBO(47, 8, 73, 0.9)),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ))),
                        items: carTypes.map((car) {
                          return DropdownMenuItem(
                            child: Text(
                              car,
                              style: TextStyle(color: Colors.grey),
                            ),
                            value: car,
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCarType = newValue.toString();
                          });
                        },
                      ),
                      SizedBox(height: 30.0),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: () {
                            _sumit();
                            //Navigator.push(context, MaterialPageRoute(builder: (c) => RegistrationVehiculoPage()));
                            print(_formKey.currentState);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(47, 8, 73, 0.5),
                            foregroundColor: Colors.white,
                            elevation: 10,
                            padding: EdgeInsets.symmetric(
                                horizontal: 45.0, vertical: 10.0),
                          ),
                          child: Text(
                            'Registrar vehículo',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tienes una cuenta?",
                            style: TextStyle(
                              color: Color.fromRGBO(47, 8, 73, 0.9),
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 20,),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                            child: Text(
                              'Ingresa',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color.fromRGBO(74, 35, 90, 0.9),
                                decoration: TextDecoration.underline,
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
          ),
          )
        ],
      ),
    );
  }
}
