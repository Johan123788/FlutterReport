import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/reporte_controller.dart';
import 'package:ojociudadano/models/reporte.dart';

class MisReportesPage extends StatefulWidget {
  final int usuarioId;

  const MisReportesPage({super.key, required this.usuarioId});

  @override
  State<MisReportesPage> createState() => _MisReportesPageState();
}

class _MisReportesPageState extends State<MisReportesPage> {
  final ReporteController controller = ReporteController();

  List<Reporte> reportes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarReportes();
  }

  Future<void> cargarReportes() async {
    final data = await controller.obtenerReportesPorUsuario(widget.usuarioId);

    setState(() {
      reportes = data;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(title: const Text("Mis Reportes"), centerTitle: true),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : reportes.isEmpty
          ? const Center(
              child: Text(
                "No tienes reportes aún",
                style: TextStyle(fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: cargarReportes,
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: reportes.length,
                itemBuilder: (context, index) {
                  final r = reportes[index];

                  return _buildReporteCard(r);
                },
              ),
            ),
    );
  }

  Widget _buildReporteCard(Reporte r) {
    Color estadoColor;

    switch (r.estado.toLowerCase()) {
      case "pendiente":
        estadoColor = Colors.orange;
        break;
      case "en proceso":
        estadoColor = Colors.blue;
        break;
      case "resuelto":
        estadoColor = Colors.green;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  DESCRIPCIÓN
            Text(
              r.descripcion,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 📊 ESTADO
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.estado,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                Text(
                  r.fecha.toString().substring(0, 10),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text("Comentario: ${r.comentario}"),

            const SizedBox(height: 5),

            //  IMAGEN (Cloudinary)
            if (r.evidencia.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  r.evidencia,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("No se pudo cargar la imagen");
                  },
                ),
              )
            else
              const Text("Sin evidencia"),

            const SizedBox(height: 10),

            Text("Categoría: ${r.categoria.nombre}"),

            const SizedBox(height: 5),

            Text("Autoridad: ${r.autoridadResponsable.nombre}"),

            const SizedBox(height: 5),

            Text("ubicacion: ${r.longitud}, ${r.latitud}"),
          ],
        ),
      ),
    );
  }
}
