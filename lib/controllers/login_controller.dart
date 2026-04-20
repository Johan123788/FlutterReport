import 'package:ojociudadano/models/usuario.dart';
import 'package:ojociudadano/services/auth_service.dart';

class LoginController {
  final AuthService _service = AuthService();

  Future<Usuario?> login(
    String correo,
    String contrasena) async {
      return await _service.login(correo, contrasena);
    }

}