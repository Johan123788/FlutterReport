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

//Contadores para cada estado
  int contar(String estado) {
  if (estado == "Todos") return reportes.length;

  return reportes
      .where((r) => r.estado.toLowerCase() == estado.toLowerCase())
      .length;
}

  // 🔥 NUEVO: filtro
  String filtro = "Todos";

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

  // 🔥 NUEVO: lista filtrada
  List<Reporte> get reportesFiltrados {
    if (filtro == "Todos") return reportes;

    return reportes
        .where((r) => r.estado.toLowerCase() == filtro.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),

    appBar: AppBar(
      title: const Text("Mis Reportes"),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    body: cargando
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              const SizedBox(height: 10),

              // 🔥 CHIPS CON CONTADOR
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    _chip("Todos", contar("Todos")),
                    _chip("Pendiente", contar("Pendiente")),
                    _chip("En proceso", contar("En proceso")),
                    _chip("Resuelto", contar("Resuelto")),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔥 LISTA CON ANIMACIÓN
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: reportesFiltrados.isEmpty
                      ? const Center(child: Text("No hay reportes"))
                      : ListView.builder(
                          key: ValueKey(filtro), // 👈 clave para animación
                          padding: const EdgeInsets.all(15),
                          itemCount: reportesFiltrados.length,
                          itemBuilder: (context, index) {
                            final r = reportesFiltrados[index];
                            return _buildReporteCard(r);
                          },
                        ),
                ),
              ),
            ],
          ),
  );
}

  // 🔵 CHIP
 Widget _chip(String texto, int cantidad) {
  final seleccionado = filtro == texto;

  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text("$texto ($cantidad)"),
      selected: seleccionado,
      onSelected: (_) {
        setState(() {
          filtro = texto;
        });
      },
      selectedColor: const Color(0xFF2D6CDF),
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : Colors.black,
      ),
    ),
  );
}

  // 🧾 CARD MEJORADA
  Widget _buildReporteCard(Reporte r) {
    Color estadoColor;
    IconData icono;

    switch (r.estado.toLowerCase()) {
      case "pendiente":
        estadoColor = Colors.red;
        icono = Icons.warning;
        break;
      case "en proceso":
        estadoColor = Colors.orange;
        icono = Icons.build;
        break;
      case "resuelto":
        estadoColor = Colors.green;
        icono = Icons.check_circle;
        break;
      default:
        estadoColor = Colors.grey;
        icono = Icons.info;
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔝 FILA
          Row(
            children: [
              Icon(icono, color: estadoColor, size: 28),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  r.descripcion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: estadoColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  r.estado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                "${r.latitud}, ${r.longitud}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (r.evidencia.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                r.evidencia,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 10),

          Text(
            r.fecha.toString().substring(0, 10),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}