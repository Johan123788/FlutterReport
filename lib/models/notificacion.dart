class Notificacion {
  final int id;
  final int usuarioId;
  final String mensaje;
  final bool leida;
  final DateTime? fecha;

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.mensaje,
    this.leida = false,
    this.fecha,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'] ?? json['Id'] ?? 0,
      usuarioId: json['usuarioId'] ?? json['UsuarioId'] ?? 0,
      mensaje: json['mensaje'] ?? json['Mensaje'] ?? '',
      leida: json['leida'] ?? json['Leida'] ?? false,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString())
          : null,
    );
  }
}