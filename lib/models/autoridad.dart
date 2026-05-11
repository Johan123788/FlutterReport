class Autoridad {
  final int id;
  final String nombre;
  final String correo;

  Autoridad({
    required this.id,
    required this.nombre,
    required this.correo,
  });

 factory Autoridad.fromJson(Map<String, dynamic> json) {
  return Autoridad(
    id: json["id"] ?? json["Id"] ?? 0,
    nombre: json["nombre"] ?? json["Nombre"] ?? "",
    correo: json["correo"] ?? json["Correo"] ?? "",
  );
}
  }
