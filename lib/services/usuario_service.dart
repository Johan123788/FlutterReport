import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ojociudadano/models/usuario.dart';

class UsuarioService {
  final String baseUrl = "https://localhost:7230/api/Usuarios";

  // REGISTRO
  Future<Usuario?> registrar(
    String nombre,
    String correo,
    String contrasena,
  ) async {
    try {
      final url = Uri.parse(baseUrl);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          //convertir objeto dart a texto json
          "nombre": nombre,
          "correo": correo,
          "contraseña": contrasena,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body); //convertir texto json a map

        return Usuario.fromJson(data); //convertir map a usuario
      }

      return null;
    } catch (e) {
      throw Exception("No se pudo conectar");
    }
  }

  // LISTAR USUARIOS
  Future<List<Usuario>> listar() async {
    try {
      final url = Uri.parse(baseUrl);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((item) => Usuario.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      throw Exception("Error al listar");
    }
  }

  Future<Usuario?> actualizar(
    int id,
    String nombre,
    String correo,
    String contrasena,
  ) async {
    final url = Uri.parse("$baseUrl/$id");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "correo": correo,
        "contraseña": contrasena,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    }
    return null;
  }

  // ELIMINAR
  Future<bool> eliminar(int id) async {
    try {
      final url = Uri.parse("$baseUrl/$id");

      final response = await http.delete(url);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
