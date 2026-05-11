import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/autoridad_controller.dart';
import 'package:ojociudadano/models/reporte.dart';

class AfiniaPage extends StatefulWidget {
  final int autoridadId;

  const AfiniaPage({super.key, required this.autoridadId});

  @override
  State<AfiniaPage> createState() => _AfiniaPageState();
}

class _AfiniaPageState extends State<AfiniaPage> {
  final AutoridadController controller = AutoridadController();
  late Future<List<Reporte>> futurosReportes;

  @override
  void initState() {
    super.initState();
    futurosReportes =
        controller.obtenerReportesPorAutoridad(widget.autoridadId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Afinia")),

      body: FutureBuilder<List<Reporte>>(
        future: futurosReportes,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reportes = snapshot.data ?? [];

          if (reportes.isEmpty) {
            return const Center(child: Text("No hay reportes"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final r = reportes[index];

              return _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      r.descripcion ?? "Sin título",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(r.descripcion ?? ""),
                  

                    const SizedBox(height: 10),

                    if (r.evidencia != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          r.evidencia!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 10),

                    Text(
                      "Estado: ${r.estado ?? "Pendiente"}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

 
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }
}