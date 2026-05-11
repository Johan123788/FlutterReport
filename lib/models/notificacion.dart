class Notificacion {
  final int id;
  final int usuarioId;
  final String mensaje;

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.mensaje,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      usuarioId: json['usuarioId'],
      mensaje: json['mensaje'],
    );
  }
}