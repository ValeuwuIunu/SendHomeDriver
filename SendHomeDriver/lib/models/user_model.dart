import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? celular;
  String? nombre;
  String? id;
  String? correo;

  UserModel({
   this.nombre,this.correo,this.id,this.celular
});

  UserModel.fromSnapshot(DataSnapshot snap){
    celular = (snap.value as dynamic)[ "phone"];
    nombre =(snap.value as dynamic)["name"];
    id = snap.key;
    correo = (snap.value as dynamic)["email"];
  }



}