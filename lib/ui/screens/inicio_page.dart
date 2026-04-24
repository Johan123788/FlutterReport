import 'package:flutter/material.dart';
import 'package:ojociudadano/ui/screens/mis_reportes_page.dart';
import 'package:ojociudadano/ui/screens/reporte_page.dart';

class HomePage extends StatelessWidget {
  final int usuarioId;
  final String nombreUsuario;

  const HomePage({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      // 🔵 HEADER
      appBar: AppBar(
        title: const Text("ReportVial"),
        backgroundColor: const Color(0xFF2D6CDF),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔵 BOTONES PRINCIPALES
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _mainButton(
                    icon: Icons.camera_alt,
                    text: "Crear Reporte",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CrearReportePage(
                            usuarioId: usuarioId,
                            nombreUsuario: nombreUsuario,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  _mainButton(
                    icon: Icons.list,
                    text: "Ver Reportes",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MisReportesPage(usuarioId: usuarioId),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  _mainButton(
                    icon: Icons.location_on,
                    text: "Ver Mapa",
                    onTap: () {
                      // luego lo implementas
                    },
                  ),
                ],
              ),
            ),

            // 📌 TITULO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Reportes recientes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🧾 LISTA DE REPORTES
            _reporteCard(
              titulo: "Hueco en la vía",
              ciudad: "Valledupar",
              estado: "Pendiente",
              color: Colors.red,
              icon: Icons.warning,
            ),

            _reporteCard(
              titulo: "Reductor dañado",
              ciudad: "Valledupar",
              estado: "En proceso",
              color: Colors.orange,
              icon: Icons.build,
            ),

            _reporteCard(
              titulo: "Señalización caída",
              ciudad: "Valledupar",
              estado: "Solucionado",
              color: Colors.green,
              icon: Icons.check_circle,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // 🔻 NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2D6CDF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }

  // 🔵 BOTONES GRANDES
  Widget _mainButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF2D6CDF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // 🧾 CARD DE REPORTE
  Widget _reporteCard({
    required String titulo,
    required String ciudad,
    required String estado,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  ciudad,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              estado,
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}