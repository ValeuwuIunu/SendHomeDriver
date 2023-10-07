import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sendhomedriver/Screens/registro_conductor.dart';
import 'package:sendhomedriver/Screens/registro_usuario.dart';
import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import 'Mapa_conductor.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  void _sumit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth.signInWithEmailAndPassword(
        email: _correoController.text.trim(),
        password: _passwordController.text.trim(),
      ).then((auth) async {

        DatabaseReference userReference = FirebaseDatabase.instance.ref().child("drivers");
        userReference.child(firebaseAuth.currentUser!.uid).once().then((value) async{
          final snap =value.snapshot;
          if(snap.value !=null){
            currentUser = auth.user;
            await Fluttertoast.showToast(msg: "Successfully Logged In");
            Navigator.push(context, MaterialPageRoute(builder: (c) => MapScreenDriver()));
          }
          else{
            await Fluttertoast.showToast(msg: "No record exist whith this email");
            firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
          }
        });

      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occurred: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
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
          appBar: AppBar(
            toolbarHeight: 80,
            titleTextStyle: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  height: 300,
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _correoController,
                              decoration: InputDecoration(
                                hintText: 'Correo electrónico',
                                labelStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black54)),
                                prefixIcon: Icon(Icons.mail, color: Colors.deepPurpleAccent),
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
                          ),
                          TextFormField(
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              hintText: 'Contraseña',
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54)),
                              prefixIcon: Icon(Icons.password, color: Colors.deepPurpleAccent),
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
                                return "La Clave no puede estar vacía";
                              }
                              if (value.length < 2) {
                                return "Por favor ingrese una clave válida";
                              }
                              if (value.length > 99) {
                                return "La Clave no puede tener más de 100 caracteres ";
                              }
                            },
                            onChanged: (value) => setState(() {
                              _passwordController.text = value;
                            }),
                          ),
                          SizedBox(height: 45),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              onPressed: () {
                                _sumit();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(47, 8, 73, 0.5),
                                foregroundColor: Colors.white,
                                elevation: 10,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 45.0, vertical: 10.0),
                              ),
                              child: Text(
                                'Ingresar',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
                            },
                            child: Center(
                              child: Text(
                                'Forgot password',
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
                                "Doesn't have an account?",
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 20,),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationConductorPage()));
                                },
                                child: Text(
                                  'Register',
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
            ),
          ),
        ),
      ),
    );
  }
}
