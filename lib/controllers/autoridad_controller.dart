import 'package:ojociudadano/models/autoridad.dart';
import 'package:ojociudadano/models/afinia.dart';
import 'package:ojociudadano/models/reporte.dart';
import 'package:ojociudadano/services/administrador/autoridad_service.dart';


class AutoridadController {

  final AutoridadService _service =
      AutoridadService();

  Future<List<Autoridad>>
      obtenerAutoridades() async {

    return await _service
        .obtenerAutoridades();
  }

Future<Autoridad?> login(
    String correo,
    String contrasena) async {
      return await _service.login(correo, contrasena);
    }

    Future<List<Reporte>> obtenerReportesPorAutoridad(int autoridadId) async {
      return await _service.ObtenerListadoReportesPorAutoridad(autoridadId);
    }





}