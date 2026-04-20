//se hace esta clase tambien en dart:
//✔ autocompletado
//✔ tipado fuerte
//✔ menos errores
//✔ más limpio
//✔ reusable
class Usuario {
  //final porque se asigna una sola vez y despues no se puede cambiar
  final int id;
  final String nombre;
  final String correo;

  Usuario({
    //sin constructor puede quedar incompleto
    required this.id, 
    required this.nombre, 
    required this.correo});

 //Se usa para crear un objeto Usuario a partir de JSON.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json["id"],
      nombre: json["nombre"],
      correo: json["correo"],
    );
  }
}
