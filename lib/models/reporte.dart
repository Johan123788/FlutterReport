import 'package:ojociudadano/models/categoria.dart';
import 'package:ojociudadano/models/autoridad.dart';

class Reporte {
  final String descripcion;
  final String estado;
  final String comentario;
  final String evidencia;

  final Categoria categoria;
  final Autoridad autoridadResponsable;

  final double latitud;
  final double longitud;

  final DateTime fecha;

  Reporte({
    required this.descripcion,
    required this.estado,
    required this.comentario,
    required this.evidencia,
    required this.categoria,
    required this.autoridadResponsable,
    required this.latitud,
    required this.longitud,
    required this.fecha,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      descripcion: json["descripcion"],
      estado: json["estado"],
      comentario: json["comentario"],
      evidencia: json["evidencia"],
      fecha: DateTime.parse(json["fecha"]),

      latitud: (json["latitud"] as num).toDouble(),
      longitud: (json["longitud"] as num).toDouble(),

      categoria: Categoria.fromJson(json["categoria"]),
      autoridadResponsable: Autoridad.fromJson(json["autoridadResponsable"]),
    );
  }
}
