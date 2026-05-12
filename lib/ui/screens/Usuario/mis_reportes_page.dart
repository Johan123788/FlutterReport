import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/reporte_controller.dart';
import 'package:ojociudadano/models/reporte.dart';
import 'package:ojociudadano/ui/screens/Usuario/user_theme.dart';

class MisReportesPage extends StatefulWidget {
  final int usuarioId;

  const MisReportesPage({super.key, required this.usuarioId});

  @override
  State<MisReportesPage> createState() => _MisReportesPageState();
}

class _MisReportesPageState extends State<MisReportesPage>
    with TickerProviderStateMixin {
  final ReporteController controller = ReporteController();
  late TabController _tabController;
  late Future<List<Reporte>> _futureReportes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _recargar();
  }

  void _recargar() {
    _futureReportes = controller.obtenerReportesPorUsuario(widget.usuarioId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UserTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: UserTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: UserTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis Reportes',
          style: TextStyle(
              color: UserTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: UserTheme.accentLight),
            onPressed: () => setState(() => _recargar()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: UserTheme.bgCard,
            child: TabBar(
              controller: _tabController,
              indicatorColor: UserTheme.accent,
              indicatorWeight: 2,
              labelColor: UserTheme.accent,
              unselectedLabelColor: UserTheme.textSecondary,
              isScrollable: true,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.all_inbox_rounded, size: 16), text: 'Todos', iconMargin: EdgeInsets.only(bottom: 2)),
                Tab(icon: Icon(Icons.pending_rounded, size: 16), text: 'Pendiente', iconMargin: EdgeInsets.only(bottom: 2)),
                Tab(icon: Icon(Icons.check_circle_rounded, size: 16), text: 'Aceptado', iconMargin: EdgeInsets.only(bottom: 2)),
                Tab(icon: Icon(Icons.cancel_rounded, size: 16), text: 'Rechazado', iconMargin: EdgeInsets.only(bottom: 2)),
                Tab(icon: Icon(Icons.verified_rounded, size: 16), text: 'Solucionado', iconMargin: EdgeInsets.only(bottom: 2)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLista(null),
          _buildLista('Pendiente'),
          _buildLista('Aceptado'),
          _buildLista('Rechazado'),
          _buildLista('Solucionado'),
        ],
      ),
    );
  }

  Widget _buildLista(String? filtro) {
    return FutureBuilder<List<Reporte>>(
      future: _futureReportes,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: UserTheme.accent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    color: UserTheme.danger, size: 48),
                const SizedBox(height: 12),
                const Text('Error al cargar reportes',
                    style: TextStyle(color: UserTheme.textSecondary)),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style:
                      TextButton.styleFrom(foregroundColor: UserTheme.accent),
                  onPressed: () => setState(() => _recargar()),
                ),
              ],
            ),
          );
        }

        final lista = filtro == null
            ? (snapshot.data ?? [])
            : (snapshot.data ?? [])
                .where((r) => r.estado == filtro)
                .toList();

        if (lista.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filtro == null
                      ? Icons.inbox_outlined
                      : UserTheme.iconEstado(filtro),
                  size: 52,
                  color: UserTheme.textSecondary.withOpacity(0.4),
                ),
                const SizedBox(height: 14),
                Text(
                  filtro == null
                      ? 'No tienes reportes aún'
                      : 'No hay reportes $filtro${filtro == 'Solucionado' ? 's' : 's'}',
                  style: const TextStyle(
                      color: UserTheme.textSecondary, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          itemCount: lista.length,
          itemBuilder: (_, i) => _buildCard(lista[i]),
        );
      },
    );
  }

  Widget _buildCard(Reporte r) {
    final color = UserTheme.colorEstado(r.estado);
    final icono = UserTheme.iconEstado(r.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: UserTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(icono, color: color, size: 18),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.estado,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${r.id}',
                  style: const TextStyle(
                      color: UserTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

          // Imagen
          if (r.evidencia.isNotEmpty)
            ClipRRect(
              child: Image.network(
                r.evidencia,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 180,
                    color: UserTheme.bgSurface,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: UserTheme.accent,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: UserTheme.bgSurface,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: UserTheme.textSecondary),
                  ),
                ),
              ),
            ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.descripcion,
                  style: const TextStyle(
                    color: UserTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (r.categoria != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.label_rounded,
                          size: 14, color: UserTheme.textSecondary),
                      const SizedBox(width: 5),
                      Text(r.categoria!.nombre,
                          style: const TextStyle(
                              color: UserTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: UserTheme.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      '${r.latitud.toStringAsFixed(4)}, ${r.longitud.toStringAsFixed(4)}',
                      style: const TextStyle(
                          color: UserTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                if (r.comentario.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: UserTheme.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            size: 14, color: UserTheme.textSecondary),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            r.comentario,
                            style: const TextStyle(
                                color: UserTheme.textSecondary,
                                fontSize: 12,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  '${r.fecha.day.toString().padLeft(2, '0')}/${r.fecha.month.toString().padLeft(2, '0')}/${r.fecha.year}',
                  style: const TextStyle(
                      color: UserTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}