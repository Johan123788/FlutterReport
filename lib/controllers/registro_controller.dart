import 'package:ojociudadano/models/usuario.dart';
import 'package:ojociudadano/services/usuario_service.dart';

class RegistroController {

  final UsuarioService _service = UsuarioService();

   Future<Usuario?> registro(
    String correo,
    String contrasena,
    String nombre) async {
      return await _service.registrar(nombre, correo, contrasena);
    }
}