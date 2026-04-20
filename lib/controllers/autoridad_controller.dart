import 'package:ojociudadano/models/autoridad.dart';
import 'package:ojociudadano/services/autoridad_service.dart';

class AutoridadController {

  final AutoridadService _service =
      AutoridadService();

  Future<List<Autoridad>>
      obtenerAutoridades() async {

    return await _service
        .obtenerAutoridades();
  }
}