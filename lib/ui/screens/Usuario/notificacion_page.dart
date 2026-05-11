import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/notificacion_controller.dart';
import 'package:ojociudadano/controllers/reporte_controller.dart';
import 'package:ojociudadano/models/notificacion.dart';
import 'package:ojociudadano/models/reporte.dart';


class NotificacionesPage extends StatefulWidget {
  final int usuarioId;

  const NotificacionesPage({super.key, required this.usuarioId});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final controller = NotificacionController();
  late Future<List<Notificacion>> futuras;

  @override
  void initState() {
    super.initState();
    futuras = controller.obtener(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notificaciones")),
      body: FutureBuilder<List<Notificacion>>(
        future: futuras,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lista = snapshot.data!;

          if (lista.isEmpty) {
            return const Center(child: Text("Sin notificaciones"));
          }

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final n = lista[i];
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(n.mensaje),
              );
            },
          );
        },
      ),
    );
  }
}
