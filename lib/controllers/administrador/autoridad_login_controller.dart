import 'package:ojociudadano/models/autoridad.dart';
import 'package:ojociudadano/services/administrador/autoridad_service.dart';

class AutoridadLoginController {
  final AutoridadService _service = AutoridadService();

  Future<Autoridad?> login(String correo, String contrasena) async {
    return await _service.login(correo, contrasena);
  }
}