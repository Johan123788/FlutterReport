import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/autoridad_controller.dart';
import 'package:ojociudadano/models/reporte.dart';
import 'package:ojociudadano/controllers/reporte_controller.dart';
import 'package:ojociudadano/ui/screens/Administrador/admin_theme.dart';
import 'package:ojociudadano/ui/screens/Administrador/dar_solucion_page.dart';

// ═══════════════════════════════════════════════
//  REPORTES POR AUTORIDAD — TABS MEJORADAS
// ═══════════════════════════════════════════════

class ReportesAutoridadPage extends StatefulWidget {
  final int autoridadId;
  final String titulo;
  final int initialTab;

  const ReportesAutoridadPage({
    super.key,
    required this.autoridadId,
    required this.titulo,
    this.initialTab = 0,
  });

  @override
  State<ReportesAutoridadPage> createState() => _ReportesAutoridadPageState();
}

class _ReportesAutoridadPageState extends State<ReportesAutoridadPage>
    with TickerProviderStateMixin {
  final AutoridadController _controller = AutoridadController();
  final ReporteController _reporteController = ReporteController();
  late TabController _tabController;
  late Future<List<Reporte>> _futureReportes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _recargar();
  }

  void _recargar() {
    _futureReportes =
        _controller.obtenerReportesPorAutoridad(widget.autoridadId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bgPrimary,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListaPorEstado('Pendiente'),
          _buildListaPorEstado('Aceptado'),
          _buildListaPorEstado('Rechazado'),
          _buildListaPorEstado('Solucionado'),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminTheme.bgCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AdminTheme.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.titulo,
        style: const TextStyle(
          color: AdminTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AdminTheme.accentLight),
          onPressed: () => setState(() => _recargar()),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AdminTheme.bgCard,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AdminTheme.accent,
            indicatorWeight: 2,
            labelColor: AdminTheme.accent,
            unselectedLabelColor: AdminTheme.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.pending_rounded, size: 16),
                text: 'Pendientes',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.check_circle_rounded, size: 16),
                text: 'Aceptados',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.cancel_rounded, size: 16),
                text: 'Rechazados',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.verified_rounded, size: 16),
                text: 'Solucionados',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Lista filtrada ────────────────────────────────────────
  Widget _buildListaPorEstado(String estado) {
    return FutureBuilder<List<Reporte>>(
      future: _futureReportes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final lista = (snapshot.data ?? [])
            .where((r) => r.estado == estado)
            .toList();

        if (lista.isEmpty) {
          return _buildEmptyState(estado);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          itemCount: lista.length,
          itemBuilder: (_, i) => _buildReporteCard(lista[i], estado),
        );
      },
    );
  }

  // ── Tarjeta de reporte ────────────────────────────────────
  Widget _buildReporteCard(Reporte r, String estado) {
    final stateColor = AdminTheme.colorEstado(estado);
    final stateIcon = AdminTheme.iconEstado(estado);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: stateColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header de la tarjeta ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: stateColor.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Icon(stateIcon, color: stateColor, size: 18),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: stateColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      color: stateColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (r.id != null)
                  Text(
                    '#${r.id}',
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // ── Imagen de evidencia ──
          if (r.evidencia != null && r.evidencia!.isNotEmpty)
            ClipRRect(
              child: Image.network(
                r.evidencia!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 180,
                    color: AdminTheme.bgSurface,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AdminTheme.accent,
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
                  color: AdminTheme.bgSurface,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: AdminTheme.textSecondary),
                  ),
                ),
              ),
            ),

          // ── Contenido ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                Text(
                  r.descripcion ?? 'Sin descripción',
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                // Categoría
                if (r.categoria != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.label_rounded,
                          size: 14, color: AdminTheme.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        r.categoria!.nombre,
                        style: const TextStyle(
                          color: AdminTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],

                // Ubicación
                if (r.latitud != 0 && r.longitud != 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AdminTheme.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        '${r.latitud.toStringAsFixed(4)}, ${r.longitud.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: AdminTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],

                // Comentario
                if (r.comentario != null && r.comentario!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminTheme.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            size: 14, color: AdminTheme.textSecondary),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            r.comentario!,
                            style: const TextStyle(
                              color: AdminTheme.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Botones acción (solo Pendiente) ──
                if (estado == 'Pendiente') ...[
                  const SizedBox(height: 14),
                  const Divider(color: AdminTheme.border, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn(
                          label: 'Aceptar',
                          icon: Icons.check_rounded,
                          color: AdminTheme.success,
                          onTap: () async {
                            await _reporteController.cambiarEstado(
                                r.id!, 'Aceptado');
                            setState(() => _recargar());
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionBtn(
                          label: 'Rechazar',
                          icon: Icons.close_rounded,
                          color: AdminTheme.danger,
                          onTap: () async {
                            await _reporteController.cambiarEstado(
                                r.id!, 'Rechazado');
                            setState(() => _recargar());
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Botón Dar Solución (solo Aceptado) ──
                if (estado == 'Aceptado') ...[
                  const SizedBox(height: 14),
                  const Divider(color: AdminTheme.border, height: 1),
                  const SizedBox(height: 14),
                  _actionBtn(
                    label: 'Dar Solución',
                    icon: Icons.build_circle_rounded,
                    color: AdminTheme.accent,
                    onTap: () async {
                      final resuelto = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DarSolucionPage(reporte: r),
                        ),
                      );
                      if (resuelto == true) {
                        setState(() => _recargar());
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estados de carga / error / vacío ─────────────────────
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AdminTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AdminTheme.danger, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Error al cargar los reportes',
            style: TextStyle(color: AdminTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: TextButton.styleFrom(foregroundColor: AdminTheme.accent),
            onPressed: () => setState(() => _recargar()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String estado) {
    final (icon, msg) = switch (estado) {
      'Aceptado'    => (Icons.check_circle_outline_rounded, 'No hay reportes aceptados'),
      'Rechazado'   => (Icons.cancel_outlined, 'No hay reportes rechazados'),
      'Solucionado' => (Icons.verified_outlined, 'No hay reportes solucionados'),
      _ => (Icons.pending_outlined, 'No hay reportes pendientes'),
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 52,
              color: AdminTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 14),
          Text(
            msg,
            style: const TextStyle(
              color: AdminTheme.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}