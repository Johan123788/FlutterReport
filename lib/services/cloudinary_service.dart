import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = "dgfkusaho";
  final String uploadPreset = "ml_default";

  Future<String?> uploadImage(File image) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", url);

      request.fields['upload_preset'] = uploadPreset;

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final res = await response.stream.bytesToString();

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: $res");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res);

        final String? url = data['secure_url'];

        print("URL CLOUDINARY EXTRAÍDA: $url");

        return url;
      }

      return null;
    } catch (e) {
      print("ERROR CLOUDINARY: $e");
      return null;
    }
  }
}
