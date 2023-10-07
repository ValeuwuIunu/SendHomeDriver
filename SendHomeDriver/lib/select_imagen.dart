import 'package:image_picker/image_picker.dart';


Future <XFile?>getImagen() async{
  final ImagePicker picker = ImagePicker();
  final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
  return imagen;

}