import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificacion.dart';

class NotificacionController {
  final String baseUrl = "http://TU_IP:PUERTO";

  Future<List<Notificacion>> obtener(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/notificaciones/$usuarioId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data
          .map<Notificacion>((e) => Notificacion.fromJson(e))
          .toList();
    } else {
      throw Exception("Error");
    }
  }
}