class Afinia {
  //final porque se asigna una sola vez y despues no se puede cambiar
  final int id;
  final String nombre;
  final String correo;

  Afinia({
    //sin constructor puede quedar incompleto
    required this.id, 
    required this.nombre, 
    required this.correo});

 //Se usa para crear un objeto Afinia a partir de JSON.
  factory Afinia.fromJson(Map<String, dynamic> json) {
    return Afinia(
      id: json["id"],
      nombre: json["nombre"],
      correo: json["correo"],
    );
  }
}
