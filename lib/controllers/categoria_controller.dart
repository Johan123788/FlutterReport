import 'package:ojociudadano/models/categoria.dart';
import 'package:ojociudadano/services/categoria_service.dart';

class CategoriaController {

  final CategoriaService _service =
      CategoriaService();

  Future<List<Categoria>>
      obtenerCategorias() async {

    return await _service
        .obtenerCategorias();
  }
}