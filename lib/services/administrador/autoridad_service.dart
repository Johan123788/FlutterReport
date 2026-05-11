import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ojociudadano/models/autoridad.dart';
import 'package:ojociudadano/models/reporte.dart';

class AutoridadService {

  

Future<Autoridad?> login(String correo, String password) async {
    try {
      //final url = Uri.parse("http://192.168.137.75:5148/api/Autoridad/login"
      final url = Uri.parse("https://localhost:7230/api/Autoridad/login");

      final response = await http.post(
        
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo, 
        "contraseña": password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Autoridad.fromJson(data);
      }

      return null;
    } catch (e) {
      throw Exception("No se pudo conectar al servidor");
    }
  }



  final String baseUrl =
      "http://192.168.137.75:5148/api/Autoridad";


      Future<List<Reporte>> ObtenerListadoReportesPorAutoridad(int autoridadId) async {
  try {
    //final url = Uri.parse("http://192.168.137.75:5148/api/Reporte/$autoridadId/reportes"
    final url = Uri.parse("https://localhost:7230/api/Reporte/$autoridadId/reportes");

    final response = await http.get(url);

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    // ✅ OK
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded.map((item) => Reporte.fromJson(item)).toList();
      } else {
        return [];
      }
    }

    // manejar 404
    if (response.statusCode == 404) {
      return []; // NO es error, solo no hay datos
    }

    throw Exception("Error HTTP: ${response.statusCode}");

  } catch (e) {
    print("ERROR REAL: $e");
    throw Exception("No se pudieron cargar los reportes");
  }
}

  Future<List<Autoridad>>
      obtenerAutoridades() async {

    try {

      final url =
          Uri.parse(baseUrl);

      final response =
          await http.get(url);

      if (response.statusCode == 200) {

        final List data =
            jsonDecode(
              response.body,
            );

        return data.map(
          (item) =>
            Autoridad.fromJson(
              item,
            ),
        ).toList();
      }

      return [];

    } catch (e) {
      throw Exception(
        "No se pudieron cargar autoridades",
      );
    }
  }
}