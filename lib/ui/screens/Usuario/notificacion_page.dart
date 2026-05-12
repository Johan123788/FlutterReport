import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/notificacion_controller.dart';
import 'package:ojociudadano/models/notificacion.dart';
import 'package:ojociudadano/ui/screens/Usuario/user_theme.dart';

class NotificacionesPage extends StatefulWidget {
  final int usuarioId;

  const NotificacionesPage({super.key, required this.usuarioId});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final controller = NotificacionController();
  late Future<List<Notificacion>> futuras;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    futuras = controller.obtener(widget.usuarioId);
    controller.marcarTodasLeidas(widget.usuarioId);
  }

  bool _esRechazado(String msg)   => msg.toLowerCase().contains('rechazado');
  bool _esAceptado(String msg)    => msg.toLowerCase().contains('aceptado');
  bool _esSolucionado(String msg) => msg.toLowerCase().contains('solucionado');

  Color _colorAccent(String msg) {
    if (_esRechazado(msg))   return UserTheme.danger;
    if (_esAceptado(msg))    return UserTheme.success;
    if (_esSolucionado(msg)) return UserTheme.accent;
    return UserTheme.accentLight;
  }

  IconData _icono(String msg) {
    if (_esRechazado(msg))   return Icons.cancel_rounded;
    if (_esAceptado(msg))    return Icons.check_circle_rounded;
    if (_esSolucionado(msg)) return Icons.verified_rounded;
    return Icons.info_rounded;
  }

  String _etiqueta(String msg) {
    if (_esRechazado(msg))   return 'Rechazado';
    if (_esAceptado(msg))    return 'Aceptado';
    if (_esSolucionado(msg)) return 'Solucionado';
    return 'Info';
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return '';
    final l = fecha.toLocal();
    final d  = l.day.toString().padLeft(2, '0');
    final mo = l.month.toString().padLeft(2, '0');
    final h  = l.hour.toString().padLeft(2, '0');
    final mi = l.minute.toString().padLeft(2, '0');
    return '${l.year}/$mo/$d  $h:$mi';
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
          'Notificaciones',
          style: TextStyle(
              color: UserTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: UserTheme.accentLight),
            onPressed: () => setState(() => _cargar()),
          ),
        ],
      ),
      body: FutureBuilder<List<Notificacion>>(
        future: futuras,
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
                  const Text('Error al cargar notificaciones',
                      style: TextStyle(color: UserTheme.textSecondary)),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                    style: TextButton.styleFrom(
                        foregroundColor: UserTheme.accent),
                    onPressed: () => setState(() => _cargar()),
                  ),
                ],
              ),
            );
          }

          final lista = snapshot.data ?? [];

          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64,
                      color: UserTheme.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin notificaciones',
                    style: TextStyle(
                        color: UserTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Aquí verás cuando tus reportes\nsean aceptados, rechazados o solucionados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: UserTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final noLeidas = lista.where((n) => !n.leida).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      '${lista.length} notificacion${lista.length == 1 ? '' : 'es'}',
                      style: const TextStyle(
                          color: UserTheme.textSecondary, fontSize: 13),
                    ),
                    if (noLeidas > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: UserTheme.danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$noLeidas nueva${noLeidas == 1 ? '' : 's'}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final n = lista[i];
                    final accent = _colorAccent(n.mensaje);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: n.leida
                            ? UserTheme.bgCard
                            : UserTheme.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: n.leida
                              ? UserTheme.border
                              : accent.withOpacity(0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: accent.withOpacity(0.12),
                          child:
                              Icon(_icono(n.mensaje), color: accent, size: 22),
                        ),
                        title: Text(
                          n.mensaje,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: n.leida
                                ? FontWeight.normal
                                : FontWeight.w600,
                            color: UserTheme.textPrimary,
                          ),
                        ),
                        subtitle: n.fecha != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatFecha(n.fecha),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: UserTheme.textSecondary),
                                ),
                              )
                            : null,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: accent.withOpacity(0.3)),
                          ),
                          child: Text(
                            _etiqueta(n.mensaje),
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: accent),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}