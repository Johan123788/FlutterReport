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
      backgroundColor: Colors.grey[100],

      appBar: AppBar(title: const Text("Ojo Ciudadano"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Text(
              "Bienvenido 👋",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              nombreUsuario,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // 🔵 CREAR REPORTE
            _buildOptionCard(
              context,
              title: "Crear Reporte",
              subtitle: "Registra una nueva denuncia o incidente",
              icon: Icons.add_circle,
              color: Colors.blue,
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

            const SizedBox(height: 20),

            // 🟢 MIS REPORTES
            _buildOptionCard(
              context,
              title: "Mis Reportes",
              subtitle: "Consulta el estado de tus reportes",
              icon: Icons.list_alt,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MisReportesPage(usuarioId: usuarioId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
