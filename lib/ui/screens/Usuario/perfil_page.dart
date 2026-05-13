import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/notificacion_controller.dart';
import 'package:ojociudadano/ui/screens/Usuario/notificacion_page.dart';
import 'package:ojociudadano/ui/screens/Usuario/user_theme.dart';
import 'package:ojociudadano/ui/screens/login_page.dart';

class PerfilPage extends StatefulWidget {
  final int usuarioId;
  final String nombreUsuario;

  const PerfilPage({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
  });

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final NotificacionController _notifController = NotificacionController();
  int _cantidadNotificaciones = 0;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      final cantidad =
          await _notifController.obtenerCantidadNoLeidas(widget.usuarioId);
      if (mounted) setState(() => _cantidadNotificaciones = cantidad);
    } catch (_) {}
  }

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: UserTheme.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
              color: UserTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '¿Estás seguro que deseas salir?',
          style: TextStyle(color: UserTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                foregroundColor: UserTheme.textSecondary),
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
              backgroundColor: UserTheme.danger,
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
    final inicial = widget.nombreUsuario.isNotEmpty
        ? widget.nombreUsuario[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: UserTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: UserTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: UserTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 40),
        child: Column(
          children: [
            // ── Avatar + nombre ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: UserTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: UserTheme.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: UserTheme.accent.withOpacity(0.15),
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: UserTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.nombreUsuario,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: UserTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.usuarioId}',
                    style: const TextStyle(
                      color: UserTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Sección: Actividad ──
            _seccionLabel('Actividad'),
            const SizedBox(height: 10),
            _opcion(
              icon: Icons.notifications_rounded,
              label: 'Notificaciones',
              badge: _cantidadNotificaciones,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NotificacionesPage(usuarioId: widget.usuarioId),
                  ),
                );
                _cargarNotificaciones();
              },
            ),
            const SizedBox(height: 32),

            // ── Botón Cerrar sesión ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmarLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UserTheme.danger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionLabel(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: UserTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _opcion({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: UserTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: UserTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: UserTheme.accentLight, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: UserTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badge > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: UserTheme.danger,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: UserTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
