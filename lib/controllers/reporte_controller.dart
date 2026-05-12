import 'package:ojociudadano/models/reporte.dart';
import 'package:ojociudadano/services/reporte_service.dart';

class ReporteController {
  final ReporteService _service = ReporteService();

  Future<Reporte?> crearReporte(
    String descripcion,
    String comentario,
    String evidencia,
    int usuarioId,
    int categoriaId,
    int autoridadId,
    double latitud,
    double longitud,
  ) async {
    return await _service.agregarReporte(
      descripcion, comentario, evidencia,
      usuarioId, categoriaId, autoridadId,
      latitud, longitud,
    );
  }

  Future<void> cambiarEstado(int reporteId, String estado) async {
    await _service.cambiarEstadoReporte(reporteId, estado);
  }

  Future<List<Reporte>> obtenerReportesPorUsuario(int usuarioId) async {
    return await _service.obtenerReportesPorUsuario(usuarioId);
  }

  // El backend maneja la notificación automáticamente en CambiarEstado
  Future<void> resolverReporte({
    required int reporteId,
    required String imagenSolucionUrl,
    required String comentarioSolucion,
  }) async {
    await _service.resolverReporte(
      reporteId: reporteId,
      imagenSolucionUrl: imagenSolucionUrl,
      comentarioSolucion: comentarioSolucion,
    );
  }
}
