import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ojociudadano/models/categoria.dart';

class CategoriaService {
  final String baseURL = "http://192.168.1.121:5148/api/Categoria";

Future<List<Categoria>> obtenerCategorias() async {

    try {

      final url = Uri.parse(baseURL);

      final response =
          await http.get(url);

      if (response.statusCode == 200) {

        final List data =
            jsonDecode(response.body);

        return data.map(
          (item) =>
            Categoria.fromJson(item)
        ).toList();
      }

      return [];

    } catch (e) {
      throw Exception(
        "No se pudieron cargar categorías"
      );
    }
}
}