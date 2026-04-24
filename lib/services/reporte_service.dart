import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ojociudadano/models/reporte.dart';

class ReporteService {
  final String baseUrl = "http://192.168.1.121:5148/api/Reporte";

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

      final url = Uri.parse(baseUrl);

      final response = await http.post(
        url,
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
          "latitud" : latitud,
          "longitud" : longitud,
          
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Reporte.fromJson(data);
      }

      throw Exception(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }



  

  Future<List<Reporte>> obtenerReportesPorUsuario(int usuarioId) async {
    final url = Uri.parse("$baseUrl/usuario/$usuarioId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Reporte.fromJson(e)).toList();
    }

    return [];
  }







  
}
