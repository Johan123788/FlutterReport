import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/autoridad_controller.dart';
import 'package:ojociudadano/models/reporte.dart';
import 'package:ojociudadano/ui/Widget/Admin%20Widget/Metric_Card.dart';
import 'package:ojociudadano/ui/screens/Administrador/admin_theme.dart';
import 'package:ojociudadano/ui/screens/Administrador/reportes_autoridad_page.dart';
import 'package:ojociudadano/ui/screens/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final int autoridadId;
  final String titulo;

  const AdminDashboardPage({
    super.key,
    required this.autoridadId,
    required this.titulo,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  final AutoridadController _controller = AutoridadController();
  late Future<List<Reporte>> _futureReportes;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _futureReportes =
        _controller.obtenerReportesPorAutoridad(widget.autoridadId);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
              color: AdminTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '¿Estás seguro que deseas salir?',
          style: TextStyle(color: AdminTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                foregroundColor: AdminTheme.textSecondary),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bgPrimary,
      body: FutureBuilder<List<Reporte>>(
        future: _futureReportes,
        builder: (context, snapshot) {
          final reportes = snapshot.data ?? [];
          final pendientes =
              reportes.where((r) => r.estado == 'Pendiente').length;
          final aceptados =
              reportes.where((r) => r.estado == 'Aceptado').length;
          final rechazados =
              reportes.where((r) => r.estado == 'Rechazado').length;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildGreeting(),
                    ),
                    const SizedBox(height: 24),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      _buildSkeletonMetrics()
                    else
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildMetricsRow(
                          total: reportes.length,
                          pendientes: pendientes,
                          aceptados: aceptados,
                          rechazados: rechazados,
                        ),
                      ),
                    const SizedBox(height: 28),
                    if (snapshot.hasData && reportes.isNotEmpty)
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildProgressBar(
                          total: reportes.length,
                          aceptados: aceptados,
                          rechazados: rechazados,
                        ),
                      ),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Módulos de gestión'),
                    const SizedBox(height: 16),
                    _buildModuloBtn(
                      icon: Icons.pending_actions_rounded,
                      label: 'Pendientes',
                      count: pendientes,
                      color: AdminTheme.warning,
                      onTap: () => _goToTab(0),
                    ),
                    const SizedBox(height: 12),
                    _buildModuloBtn(
                      icon: Icons.check_circle_rounded,
                      label: 'Aceptados',
                      count: aceptados,
                      color: AdminTheme.success,
                      onTap: () => _goToTab(1),
                    ),
                    const SizedBox(height: 12),
                    _buildModuloBtn(
                      icon: Icons.cancel_rounded,
                      label: 'Rechazados',
                      count: rechazados,
                      color: AdminTheme.danger,
                      onTap: () => _goToTab(2),
                    ),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Acceso rápido'),
                    const SizedBox(height: 16),
                    _buildAccesoRapido(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Últimos reportes'),
                    const SizedBox(height: 16),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      _buildSkeletonList()
                    else if (reportes.isEmpty)
                      _buildEmptyState()
                    else
                      ...reportes.take(3).map((r) => _buildReportePreview(r)),
                    if (reportes.length > 3) _buildVerTodosBtn(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final gradient = _gradientPorAutoridad(widget.titulo);
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: AdminTheme.bgCard,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _iconPorAutoridad(widget.titulo),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Panel de administración',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => setState(() {
            _futureReportes =
                _controller.obtenerReportesPorAutoridad(widget.autoridadId);
          }),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          tooltip: 'Cerrar sesión',
          onPressed: _confirmarLogout,
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '¡Buenos días!'
        : hour < 18
            ? '¡Buenas tardes!'
            : '¡Buenas noches!';
    return Row(
      children: [
        Text(
          greeting,
          style: const TextStyle(
            color: AdminTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        const Text('👋', style: TextStyle(fontSize: 20)),
      ],
    );
  }

  Widget _buildMetricsRow({
    required int total,
    required int pendientes,
    required int aceptados,
    required int rechazados,
  }) {
    return Column(
      children: [
        MetricCard    (
          label: 'Total de reportes',
          value: total.toString(),
          icon: Icons.bar_chart_rounded,
          color: AdminTheme.accent,
          wide: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Pendientes',
                value: pendientes.toString(),
                icon: Icons.pending_rounded,
                color: AdminTheme.warning,
                wide: false,      
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard (
                label: 'Aceptados',
                value: aceptados.toString(),
                icon: Icons.check_circle_rounded,
                color: AdminTheme.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Rechazados',
                value: rechazados.toString(),
                icon: Icons.cancel_rounded,
                color: AdminTheme.danger,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required int total,
    required int aceptados,
    required int rechazados,
  }) {
    final pendientes = total - aceptados - rechazados;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución de reportes',
            style: TextStyle(
              color: AdminTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (aceptados > 0)
                  Expanded(
                    flex: aceptados,
                    child: Container(height: 10, color: AdminTheme.success),
                  ),
                if (pendientes > 0)
                  Expanded(
                    flex: pendientes,
                    child: Container(height: 10, color: AdminTheme.warning),
                  ),
                if (rechazados > 0)
                  Expanded(
                    flex: rechazados,
                    child: Container(height: 10, color: AdminTheme.danger),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _legendaDot(AdminTheme.success, 'Aceptados'),
              const SizedBox(width: 16),
              _legendaDot(AdminTheme.warning, 'Pendientes'),
              const SizedBox(width: 16),
              _legendaDot(AdminTheme.danger, 'Rechazados'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendaDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AdminTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildModuloBtn({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AdminTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AdminTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AdminTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesoRapido() {
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            icon: Icons.list_alt_rounded,
            label: 'Ver todos\nlos reportes',
            color: AdminTheme.accent,
            onTap: () => _goToTab(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            icon: Icons.download_rounded,
            label: 'Exportar\nreportes',
            color: const Color(0xFF8B5CF6),
            onTap: () => _showComingSoon(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            icon: Icons.notifications_rounded,
            label: 'Notifi-\ncaciones',
            color: const Color(0xFFEC4899),
            onTap: () => _showComingSoon(),
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AdminTheme.textSecondary,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportePreview(Reporte r) {
    final color = AdminTheme.colorEstado(r.estado ?? 'Pendiente');
    final icon = AdminTheme.iconEstado(r.estado ?? 'Pendiente');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.descripcion ?? 'Sin descripción',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  r.estado ?? 'Pendiente',
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ],
            ),
          ),
          if (r.evidencia != null && r.evidencia!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                r.evidencia!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerTodosBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: () => _goToTab(0),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AdminTheme.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Ver todos los reportes →',
            style: TextStyle(
              color: AdminTheme.accentLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonMetrics() {
    return Column(
      children: [
        _skeletonBox(height: 80),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _skeletonBox(height: 80)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonBox(height: 80)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonBox(height: 80)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _skeletonBox(height: 60),
        ),
      ),
    );
  }

  Widget _skeletonBox({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AdminTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_rounded,
              size: 48,
              color: AdminTheme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text(
            'No hay reportes todavía',
            style: TextStyle(color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AdminTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }

  void _goToTab(int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportesAutoridadPage(
          autoridadId: widget.autoridadId,
          titulo: widget.titulo,
          initialTab: tabIndex,
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AdminTheme.bgSurface,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text(
          '🚧 Próximamente disponible',
          style: TextStyle(color: AdminTheme.textPrimary),
        ),
      ),
    );
  }

  LinearGradient _gradientPorAutoridad(String titulo) {
    final t = titulo.toLowerCase();
    if (t.contains('afinia')) return AdminTheme.gradientAfinia;
    if (t.contains('alcaldia') || t.contains('alcaldía'))
      return AdminTheme.gradientAlcaldia;
    return AdminTheme.gradientInteraseo;
  }

  IconData _iconPorAutoridad(String titulo) {
    final t = titulo.toLowerCase();
    if (t.contains('afinia')) return Icons.electric_bolt_rounded;
    if (t.contains('alcaldia') || t.contains('alcaldía'))
      return Icons.account_balance_rounded;
    return Icons.delete_rounded;
  }
}