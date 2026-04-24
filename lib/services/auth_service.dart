import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ojociudadano/models/usuario.dart';

class AuthService {
  Future<Usuario?> login(String correo, String password) async {
    try {
      final url = Uri.parse("http://192.168.1.121:5148/api/Usuarios/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo, 
        "contraseña": password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Usuario.fromJson(data);
      }

      return null;
    } catch (e) {
      throw Exception("No se pudo conectar al servidor");
    }
  }
}
