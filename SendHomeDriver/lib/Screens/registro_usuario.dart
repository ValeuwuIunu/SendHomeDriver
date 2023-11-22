import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../global/global.dart';
import 'LoginScreen.dart';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _numUserController = TextEditingController();
  final _nombreUserController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordUserController = TextEditingController();
  final _passwordCUserController = TextEditingController();

  bool _passwordVisible = false;

  void _sumit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: _correoController.text.trim(),
        password: _passwordUserController.text.trim(),
      ).then((value) async {
        currentUser = value.user;
        if (currentUser != null) {
          Map userMap = {
            "id": currentUser!.uid,
            "name": _nombreUserController.text.trim(),
            "email": _correoController.text.trim(),
            "phone": _numUserController.text.trim(),
          };
          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Registrado exitosamente");
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Ocurrió un error: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "No todos los campos han sido digitados");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(204, 200, 236, 1.0),
      appBar: AppBar(
        toolbarHeight: 80 ,
        titleTextStyle: const TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(9.5),
            child: Card(
              color: Color.fromRGBO(185, 175, 224, 1.0),
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: EdgeInsets.all(28.5),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IntlPhoneField(
                        showCountryFlag: false,
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.deepPurpleAccent,
                        ),
                        decoration: InputDecoration(
                          hintText: "Número",
                          hintStyle: TextStyle(
                            color: Colors.grey,
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
                            borderSide: BorderSide(
                                color: Colors.blue),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          prefixIcon: Icon(Icons.person, color: Colors.deepPurpleAccent),
                        ),
                        cursorColor: Colors.blue,
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
                            borderSide: BorderSide(
                                color: Colors.blue),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          prefixIcon: Icon(Icons.mail,color: Colors.deepPurpleAccent),
                        ),
                        cursorColor: Colors.blue,
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
                            borderSide: BorderSide(
                                color: Colors.blue),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          prefixIcon: Icon(Icons.password,color: Colors.deepPurpleAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.deepPurpleAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        cursorColor: Colors.blue,
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
                            borderSide: BorderSide(
                                color: Colors.blue),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          prefixIcon: Icon(Icons.password,color: Colors.deepPurpleAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.deepPurpleAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        cursorColor: Colors.blue,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La contraseña no puede estar vacía";
                          }
                          if (value != _passwordUserController.text) {
                            return "La contraseña no coincide";
                          }
                          if (value.length < 2) {
                            return "Por favor ingrese una clave válida";
                          }
                          if (value.length > 99) {
                            return "La clave no puede tener más de 100 caracteres ";
                          }
                        },
                        onChanged: (value) => setState(() {
                          _passwordCUserController.text = value;
                        }),
                      ),
                      SizedBox(height: 70.0),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: () {
                            _sumit();
                            print(_formKey.currentState);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(47, 8, 73, 0.5),
                            foregroundColor: Colors.white,
                            elevation: 10,
                            padding: EdgeInsets.symmetric(
                                horizontal: 45.0,
                                vertical: 10.0),
                          ),
                          child: Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      GestureDetector(
                        onTap: (){},
                        child: Center(
                          child: Text(
                            '¿Olvidó contraseña?',
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
                            "Tienes una cuenta?",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 20,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context,MaterialPageRoute(builder: (context) => LoginScreen()));
                            },
                            child: Text(
                              'Registrese',
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
          ),
        ],
      ),
    );
  }
}
