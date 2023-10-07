import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendhomedriver/Screens/registro_conductor.dart';
import 'package:sendhomedriver/select_imagen.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imagen_to_upload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Material App Bar"),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () async {
              final imagen = await getImagen();
              setState(() {
                imagen_to_upload = File(imagen!.path);
              });
            },
            child: Container(
              margin: EdgeInsets.all(10),
              height: 500,
              width: 500,
              color: Colors.deepPurpleAccent,
              child: imagen_to_upload != null
                  ? Image.file(
                imagen_to_upload!,
                width: 500,
                height: 500,
                fit: BoxFit.contain, // Ajustar la imagen al Container
              )
                  : Icon(
                Icons.camera_alt,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Tu lógica para subir la imagen a Firebase aquí
              Navigator.push(context, MaterialPageRoute(builder: (c) => RegistrationConductorPage()));
              print(imagen_to_upload);
            },
            child: Text("Subir a Firebase"),
          ),
        ],
      ),
    );
  }
}