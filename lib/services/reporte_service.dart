import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ojociudadano/models/reporte.dart';

class ReporteService {
  //final String baseUrl = "http://192.168.137.75:5148/api/Reporte";
  final String baseUrl = "https://localhost:7230/api/Reporte";

  Future<Reporte?> agregarReporte(
    String descripcion,
    String comentario,
    String evidencia,
    int usuarioId,
    int categoriaId,
    int autoridadId,
    double longitud,
    double latitud,
  ) async {
    try {
      if (evidencia.isEmpty) {
        throw Exception("La evidencia es obligatoria");
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "descripcion": descripcion,
          "estado": "Pendiente",
          "comentario": comentario,
          "evidencia": evidencia,
          "usuarioId": usuarioId,
          "categoriaId": categoriaId,
          "autoridadId": autoridadId,
          "fecha": DateTime.now().toIso8601String(),
          "latitud": latitud,
          "longitud": longitud,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Reporte.fromJson(jsonDecode(response.body));
      }
      throw Exception(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Reporte>> obtenerReportesPorUsuario(int usuarioId) async {
    final response = await http.get(Uri.parse("$baseUrl/usuario/$usuarioId"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Reporte.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> cambiarEstadoReporte(int reporteId, String nuevoEstado) async {
    final response = await http.put(
      Uri.parse("$baseUrl/cambiar-estado/$reporteId"),
      headers: {"Content-Type": "application/json"},
      body: '"$nuevoEstado"',
    );
    if (response.statusCode != 200) {
      throw Exception("Error al cambiar estado: ${response.body}");
    }
  }

  // ── Dar solución: cambia a "Solucionado" y sube la imagen de evidencia.
  // La notificación la maneja el backend en CambiarEstado automáticamente.
  //Future<void> resolverReporte({
   // required int reporteId,
    //required String imagenSolucionUrl,
    //required String comentarioSolucion,
  //}) async {
    // 1. Cambiar estado → el backend crea la notificación solo
    //await cambiarEstadoReporte(reporteId, 'Solucionado');

    // 2. Guardar imagen de evidencia de solución (endpoint opcional)
    //if (imagenSolucionUrl.isNotEmpty) {
      //await http.put(
        //Uri.parse("$baseUrl/$reporteId/evidencia-solucion"),
        //headers: {"Content-Type": "application/json"},
        //body: jsonEncode({
          //"evidenciaSolucion": imagenSolucionUrl,
          //"comentarioSolucion": comentarioSolucion,
        //}),
      //);
      //
      // No lanzamos excepción si falla — el campo es opcional

Future<void> resolverReporte({
  required int reporteId,
  required String imagenSolucionUrl,
  required String comentarioSolucion,
}) async {
  await cambiarEstadoReporte(reporteId, 'Solucionado');
}

    
  }
