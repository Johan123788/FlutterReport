import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/notificacion_controller.dart';
import 'package:ojociudadano/controllers/reporte_controller.dart';
import 'package:ojociudadano/models/reporte.dart';
import 'package:ojociudadano/ui/screens/Usuario/mis_reportes_page.dart';
import 'package:ojociudadano/ui/screens/Usuario/notificacion_page.dart';
import 'package:ojociudadano/ui/screens/Usuario/perfil_page.dart';
import 'package:ojociudadano/ui/screens/Usuario/reporte_page.dart';
import 'package:ojociudadano/ui/screens/Usuario/user_theme.dart';

class HomePage extends StatefulWidget {
  final int usuarioId;
  final String nombreUsuario;

  const HomePage({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificacionController _notifController = NotificacionController();
  final ReporteController _reporteController = ReporteController();

  int _cantidadNotificaciones = 0;
  List<Reporte> _reportesRecientes = [];
  bool _cargandoReportes = true;

  // ── Tab activo del IndexedStack ──
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarCantidadNotificaciones();
    _cargarReportesRecientes();
  }

  Future<void> _cargarCantidadNotificaciones() async {
    try {
      final cantidad =
          await _notifController.obtenerCantidadNoLeidas(widget.usuarioId);
      if (mounted) setState(() => _cantidadNotificaciones = cantidad);
    } catch (_) {}
  }

  Future<void> _cargarReportesRecientes() async {
    try {
      final lista =
          await _reporteController.obtenerReportesPorUsuario(widget.usuarioId);
      if (mounted) {
        setState(() {
          _reportesRecientes = lista.take(3).toList();
          _cargandoReportes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargandoReportes = false);
    }
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      // Reportes → página propia con Navigator
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MisReportesPage(usuarioId: widget.usuarioId),
        ),
      ).then((_) => _cargarReportesRecientes());
      return;
    }

    if (index == 2) {
      // Mapa → próximamente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El mapa estará disponible próximamente'),
          backgroundColor: UserTheme.bgCard,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Inicio (0) y Perfil (3) → cambian el IndexedStack
    setState(() => _tabIndex = index == 3 ? 1 : 0);
  }

  // Convierte _tabIndex interno al índice del BottomNavigationBar
  int get _navBarIndex => _tabIndex == 1 ? 3 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UserTheme.bgPrimary,
      // ── AppBar dinámico según tab activo ──
      appBar: AppBar(
        backgroundColor: UserTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _tabIndex == 1 ? 'Mi Perfil' : 'OjoCiudadano',
          style: const TextStyle(
            color: UserTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_tabIndex == 0) ...[
            // Solo en Inicio: campana de notificaciones
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded,
                      color: UserTheme.accentLight),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NotificacionesPage(usuarioId: widget.usuarioId),
                      ),
                    );
                    _cargarCantidadNotificaciones();
                  },
                ),
                if (_cantidadNotificaciones > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: UserTheme.danger,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        _cantidadNotificaciones > 99
                            ? '99+'
                            : '$_cantidadNotificaciones',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),

      // ── IndexedStack: mantiene el estado de cada página ──
      body: IndexedStack(
        index: _tabIndex,
        children: [
          // Página 0 → Inicio
          _buildInicio(),

          // Página 1 → Perfil
          PerfilPage(
            usuarioId: widget.usuarioId,
            nombreUsuario: widget.nombreUsuario,
          ),
        ],
      ),

      // ── Barra de navegación inferior ──
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: UserTheme.bgCard,
          border: Border(top: BorderSide(color: UserTheme.border)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: UserTheme.accent,
          unselectedItemColor: UserTheme.textSecondary,
          currentIndex: _navBarIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Inicio'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.storage_rounded), label: 'Reportes'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.location_on_rounded), label: 'Mapa'),
            BottomNavigationBarItem(
              label: 'Perfil',
              icon: _cantidadNotificaciones > 0
                  ? Badge(
                      label: Text(
                        _cantidadNotificaciones > 99
                            ? '99+'
                            : '$_cantidadNotificaciones',
                        style: const TextStyle(fontSize: 9),
                      ),
                      child: const Icon(Icons.person_rounded),
                    )
                  : const Icon(Icons.person_rounded),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contenido de la página Inicio ──
  Widget _buildInicio() {
    return RefreshIndicator(
      color: UserTheme.accent,
      backgroundColor: UserTheme.bgCard,
      onRefresh: () async {
        await Future.wait([
          _cargarCantidadNotificaciones(),
          _cargarReportesRecientes(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${widget.nombreUsuario} 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: UserTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '¿Qué quieres reportar hoy?',
              style:
                  TextStyle(color: UserTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _mainButton(
              icon: Icons.camera_alt_rounded,
              text: 'Crear Reporte',
              color: UserTheme.accent,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CrearReportePage(
                      usuarioId: widget.usuarioId,
                      nombreUsuario: widget.nombreUsuario,
                    ),
                  ),
                );
                _cargarReportesRecientes();
              },
            ),
            const SizedBox(height: 12),
            _mainButton(
              icon: Icons.list_alt_rounded,
              text: 'Mis Reportes',
              color: UserTheme.bgSurface,
              textColor: UserTheme.textPrimary,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MisReportesPage(usuarioId: widget.usuarioId),
                  ),
                );
                _cargarReportesRecientes();
              },
            ),
            const SizedBox(height: 12),
            _mainButton(
              icon: Icons.location_on_rounded,
              text: 'Ver Mapa',
              color: UserTheme.bgSurface,
              textColor: UserTheme.textSecondary,
              disabled: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'El mapa estará disponible próximamente'),
                    backgroundColor: UserTheme.bgCard,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reportes recientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: UserTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MisReportesPage(usuarioId: widget.usuarioId),
                    ),
                  ),
                  child: const Text(
                    'Ver todos',
                    style:
                        TextStyle(color: UserTheme.accentLight, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_cargandoReportes)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(color: UserTheme.accent),
                ),
              )
            else if (_reportesRecientes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: UserTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: UserTheme.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: UserTheme.textSecondary),
                    SizedBox(height: 10),
                    Text(
                      'Aún no tienes reportes.\nPresiona "Crear Reporte" para empezar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: UserTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ..._reportesRecientes.map((r) => _reporteCard(r)),
          ],
        ),
      ),
    );
  }

  Widget _mainButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = UserTheme.accent,
    Color textColor = Colors.white,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: disabled ? color.withOpacity(0.4) : color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UserTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: disabled ? UserTheme.textSecondary : textColor,
                size: 22),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                color: disabled ? UserTheme.textSecondary : textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (disabled) ...[
              const SizedBox(width: 8),
              const Text(
                '(próximamente)',
                style: TextStyle(
                    color: UserTheme.textSecondary, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _reporteCard(Reporte r) {
    final color = UserTheme.colorEstado(r.estado);
    final icono = UserTheme.iconEstado(r.estado);
    final d = r.fecha.day.toString().padLeft(2, '0');
    final mo = r.fecha.month.toString().padLeft(2, '0');
    final fechaStr = '$d/$mo/${r.fecha.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UserTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.descripcion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: UserTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fechaStr,
                  style: const TextStyle(
                      color: UserTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              r.estado,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}