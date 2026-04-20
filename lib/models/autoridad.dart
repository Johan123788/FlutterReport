class Autoridad {
  final int id;
  final String nombre;

  Autoridad({
    required this.id,
    required this.nombre,
  });

  factory Autoridad.fromJson(
    Map<String,dynamic> json,
  ) {
    return Autoridad(
      id: json["id"],
      nombre: json["nombre"],
    );
  }
}