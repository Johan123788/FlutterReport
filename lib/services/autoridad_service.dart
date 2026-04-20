import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ojociudadano/models/autoridad.dart';

class AutoridadService {

  final String baseUrl =
      "https://localhost:7230/api/Autoridad";

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