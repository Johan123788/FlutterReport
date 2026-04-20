import 'dart:convert';
import 'package:http/http.dart' as http;

class IaService {
  final String baseUrl = "https://localhost:7230/api/Ia";

  Future<Map<String, dynamic>> analizarTexto(String descripcion) async {
    final url = Uri.parse("$baseUrl/analizarDescripcion");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"descripcion": descripcion}),
    );

    print("STATUS IA: ${response.statusCode}");
    print("BODY IA: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }
}
