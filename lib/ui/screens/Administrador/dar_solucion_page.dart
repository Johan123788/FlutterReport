import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ojociudadano/controllers/reporte_controller.dart';
import 'package:ojociudadano/models/reporte.dart';
import 'package:ojociudadano/services/cloudinary_service.dart';
import 'package:ojociudadano/ui/screens/Administrador/admin_theme.dart';

class DarSolucionPage extends StatefulWidget {
  final Reporte reporte;
  const DarSolucionPage({super.key, required this.reporte});

  @override
  State<DarSolucionPage> createState() => _DarSolucionPageState();
}

class _DarSolucionPageState extends State<DarSolucionPage> {
  File? _imagenSolucion;
  final TextEditingController _comentarioCtrl = TextEditingController();
  bool _cargando = false;
  String? _errorMsg;

  final _reporteController = ReporteController();
  final _cloudinary = CloudinaryService();
  final _picker = ImagePicker();

  // ── Seleccionar imagen ────────────────────────────────────
  Future<void> _seleccionarImagen(ImageSource source) async {
    final XFile? foto = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (foto == null) return;
    setState(() => _imagenSolucion = File(foto.path));
    if (mounted) Navigator.pop(context);
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AdminTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 12),
                child: Text(
                  'Evidencia de la solución',
                  style: TextStyle(
                    color: AdminTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              _opcionImagen(
                icon: Icons.camera_alt_rounded,
                label: 'Tomar foto',
                sub: 'Abre la cámara del dispositivo',
                onTap: () => _seleccionarImagen(ImageSource.camera),
              ),
              const SizedBox(height: 10),
              _opcionImagen(
                icon: Icons.photo_library_rounded,
                label: 'Galería',
                sub: 'Selecciona desde tus fotos',
                onTap: () => _seleccionarImagen(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opcionImagen({
    required IconData icon,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AdminTheme.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AdminTheme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AdminTheme.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    color: AdminTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Guardar solución ──────────────────────────────────────
  Future<void> _guardarSolucion() async {
    final comentario = _comentarioCtrl.text.trim();

    if (_imagenSolucion == null) {
      setState(
        () =>
            _errorMsg = 'Por favor toma o selecciona una foto de la solución.',
      );
      return;
    }
    if (comentario.isEmpty) {
      setState(
        () => _errorMsg = 'Escribe un comentario describiendo la solución.',
      );
      return;
    }

    setState(() {
      _cargando = true;
      _errorMsg = null;
    });

    try {
      // 1. Subir imagen a Cloudinary
      final urlImagen = await _cloudinary.uploadImage(_imagenSolucion!);
      if (urlImagen == null) throw Exception('Error al subir la imagen.');

      // 2. Cambiar estado a Solucionado
      //    El backend crea la notificación automáticamente en CambiarEstado
      await _reporteController.resolverReporte(
        reporteId: widget.reporte.id,
        imagenSolucionUrl: urlImagen,
        comentarioSolucion: comentario,
      );

      if (!mounted) return;
      _mostrarExito();
    } catch (e) {
      setState(() => _errorMsg = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminTheme.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AdminTheme.success,
                size: 52,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Reporte solucionado!',
              style: TextStyle(
                color: AdminTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'El ciudadano ha sido notificado sobre la solución.',
              style: TextStyle(
                color: AdminTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // cerrar diálogo
                  Navigator.pop(context, true); // volver y recargar lista
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build principal ───────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final r = widget.reporte;
    return Scaffold(
      backgroundColor: AdminTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AdminTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AdminTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dar Solución',
          style: TextStyle(
            color: AdminTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _seccion('Reporte a solucionar', Icons.assignment_rounded),
            const SizedBox(height: 12),
            _tarjetaReporte(r),
            const SizedBox(height: 24),
            _seccion('Foto de la solución', Icons.photo_camera_rounded),
            const SizedBox(height: 12),
            _areaDeFoto(),
            const SizedBox(height: 24),
            _seccion('Descripción de la solución', Icons.edit_note_rounded),
            const SizedBox(height: 12),
            _campoComentario(),
            const SizedBox(height: 16),
            if (_errorMsg != null) _mensajeError(),
            const SizedBox(height: 8),
            _botonGuardar(),
          ],
        ),
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────

  Widget _seccion(String titulo, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AdminTheme.accent, size: 18),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            color: AdminTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _tarjetaReporte(Reporte r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AdminTheme.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${r.id}',
                  style: const TextStyle(
                    color: AdminTheme.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (r.categoria != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AdminTheme.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.categoria!.nombre,
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.descripcion,
            style: const TextStyle(
              color: AdminTheme.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (r.evidencia.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                r.evidencia,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _areaDeFoto() {
    return GestureDetector(
      onTap: _mostrarOpcionesImagen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _imagenSolucion != null ? 220 : 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AdminTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imagenSolucion != null
                ? AdminTheme.success.withOpacity(0.5)
                : AdminTheme.border,
            width: _imagenSolucion != null ? 2 : 1,
          ),
        ),
        child: _imagenSolucion != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_imagenSolucion!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _imagenSolucion = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xCC000000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _mostrarOpcionesImagen,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC000000),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Cambiar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AdminTheme.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      color: AdminTheme.accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toca para agregar foto',
                    style: TextStyle(
                      color: AdminTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Evidencia de la solución aplicada',
                    style: TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _campoComentario() {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      child: TextField(
        controller: _comentarioCtrl,
        maxLines: 4,
        style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText:
              'Describe qué se hizo para solucionar el problema reportado...',
          hintStyle: TextStyle(
            color: AdminTheme.textSecondary.withOpacity(0.6),
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _mensajeError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AdminTheme.danger,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMsg!,
              style: const TextStyle(color: AdminTheme.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminTheme.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: _cargando ? null : _guardarSolucion,
        icon: _cargando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check_circle_rounded, size: 20),
        label: Text(
          _cargando ? 'Guardando...' : 'Marcar como Solucionado',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }
}
