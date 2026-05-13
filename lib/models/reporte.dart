import 'package:ojociudadano/models/autoridad.dart';
import 'package:ojociudadano/models/categoria.dart';

class Reporte {
  final int id;
  final String descripcion;
  final String estado;
  final String comentario;
  final String evidencia;

  final int? usuarioId; // ID del ciudadano que reportó
  final Categoria? categoria;
  final Autoridad? autoridadResponsable;

  final double latitud;
  final double longitud;

  final DateTime fecha;

  Reporte({
    required this.id,
    required this.descripcion,
    required this.estado,
    required this.comentario,
    required this.evidencia,
    this.usuarioId,
    required this.categoria,
    required this.autoridadResponsable,
    required this.latitud,
    required this.longitud,
    required this.fecha,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: json["id"] ?? json["Id"] ?? 0,
      descripcion: json["descripcion"] ?? "",
      estado: json["estado"] ?? "",
      comentario: json["comentario"] ?? "",
      evidencia: json["evidencia"] ?? "",
      usuarioId: json["usuarioId"] ?? json["UsuarioId"],
      fecha: DateTime.parse(json["fecha"]),

      latitud: (json["latitud"] as num).toDouble(),
      longitud: (json["longitud"] as num).toDouble(),

      categoria: json["categoria"] != null
          ? Categoria.fromJson(json["categoria"])
          : null,

      autoridadResponsable: json["autoridadResponsable"] != null
          ? Autoridad.fromJson(json["autoridadResponsable"])
          : null,
    );
  }
}
