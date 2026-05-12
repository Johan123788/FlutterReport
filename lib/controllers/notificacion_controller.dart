import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ojociudadano/models/notificacion.dart';

class NotificacionController {
  // 🔧 Cambia esto por tu IP y puerto reales
  final String baseUrl = "https://localhost:7230";

  // 📋 GET api/notificacion/{usuarioId}
  // Obtener todas las notificaciones de un usuario (ordenadas más recientes primero)
  Future<List<Notificacion>> obtener(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/notificacion/$usuarioId"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Notificacion>((e) => Notificacion.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener notificaciones");
    }
  }

  // 🔢 GET api/notificacion/{usuarioId}/cantidad
  // Devuelve cuántas notificaciones NO leídas tiene el usuario (para el badge rojo)
  Future<int> obtenerCantidadNoLeidas(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/notificacion/$usuarioId/cantidad"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    }
    return 0;
  }

  // ✅ PUT api/notificacion/{usuarioId}/marcar-todas-leidas
  // Marca todas como leídas (se llama al abrir la pantalla de notificaciones)
  Future<void> marcarTodasLeidas(int usuarioId) async {
    await http.put(
      Uri.parse("$baseUrl/api/notificacion/$usuarioId/marcar-todas-leidas"),
    );
  }

  // 🗑 DELETE api/notificacion/{id}
  Future<void> eliminar(int notificacionId) async {
    await http.delete(
      Uri.parse("$baseUrl/api/notificacion/$notificacionId"),
    );
  }
}