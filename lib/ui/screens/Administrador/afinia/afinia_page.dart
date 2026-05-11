import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/autoridad_controller.dart';
import 'package:ojociudadano/models/reporte.dart';
import 'package:ojociudadano/controllers/reporte_controller.dart';

class ReportesAutoridadPage extends StatefulWidget {
  final int autoridadId;
  final String titulo;

  const ReportesAutoridadPage({
    super.key,
    required this.autoridadId,
    required this.titulo,
  });

  @override
  State<ReportesAutoridadPage> createState() =>
      _ReportesAutoridadPageState();
}

class _ReportesAutoridadPageState
    extends State<ReportesAutoridadPage> {
  final AutoridadController controller = AutoridadController();
  final ReporteController reporteController = ReporteController();
  late Future<List<Reporte>> futurosReportes;

  @override
  void initState() {
    super.initState();
    recargar();
  }

  void recargar() {
    futurosReportes =
        controller.obtenerReportesPorAutoridad(widget.autoridadId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.titulo),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pendientes"),
              Tab(text: "Aceptados"),
              Tab(text: "Rechazados"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            _listaPorEstado("Pendiente"),
            _listaPorEstado("Aceptado"),
            _listaPorEstado("Rechazado"),
          ],
        ),
      ),
    );
  }

  // 🔥 LISTA FILTRADA
  Widget _listaPorEstado(String estado) {
    return FutureBuilder<List<Reporte>>(
      future: futurosReportes,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text("Error al cargar"));
        }

        final lista = (snapshot.data ?? [])
            .where((r) => r.estado == estado)
            .toList();

        if (lista.isEmpty) {
          return Center(child: Text("No hay $estado"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: lista.length,
          itemBuilder: (_, i) {
            final r = lista[i];

            return _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📝 DESCRIPCIÓN
                  Text(
                    r.descripcion ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🖼 IMAGEN
                  if (r.evidencia != null &&
                      r.evidencia!.isNotEmpty)
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

                  // 📌 ESTADO
                  Text(
                    "Estado: ${r.estado}",
                    style:
                        const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  // 🔥 BOTONES SOLO EN PENDIENTES
                  if (estado == "Pendiente")
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            await reporteController.cambiarEstado(
                                r.id!, "Aceptado");

                            setState(() {
                              recargar();
                            });
                          },
                          child: const Text("Aceptar"),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await reporteController.cambiarEstado(
                                r.id!, "Rechazado");

                            setState(() {
                              recargar();
                            });
                          },
                          child: const Text("Rechazar"),
                        ),
                      ],
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🎨 CARD
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }
}