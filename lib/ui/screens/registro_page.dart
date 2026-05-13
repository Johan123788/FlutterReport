import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/registro_controller.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  // ── Paleta ──────────────────────────────────────────────
  static const _bgPrimary  = Color(0xFF0F1117);
  static const _bgCard     = Color(0xFF1C1F26);
  static const _bgField    = Color(0xFF252830);
  static const _accent     = Color(0xFF3D6CF4);
  static const _textPrimary   = Color(0xFFFFFFFF);
  static const _textSecondary = Color(0xFF8B8FA8);
  static const _border     = Color(0xFF2E3140);
  // ────────────────────────────────────────────────────────

  final _nombreCtrl    = TextEditingController();
  final _correoCtrl    = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  final _controller = RegistroController();

  bool _cargando       = false;
  bool _verContrasena  = false;

  Future<void> _registrar() async {
    final nombre    = _nombreCtrl.text.trim();
    final correo    = _correoCtrl.text.trim();
    final contrasena = _contrasenaCtrl.text.trim();

    if (nombre.isEmpty || correo.isEmpty || contrasena.isEmpty) {
      _snack('Por favor completa todos los campos');
      return;
    }

    setState(() => _cargando = true);

    try {
      final usuario = await _controller.registro(correo, contrasena, nombre);
      if (!mounted) return;

      if (usuario != null) {
        _snack('¡Bienvenido, ${usuario.nombre}!', success: true);
        Navigator.pop(context);
      } else {
        _snack('No se pudo crear la cuenta. Intenta de nuevo.');
      }
    } catch (e) {
      if (mounted) _snack('Error: $e');
    }

    if (mounted) setState(() => _cargando = false);
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: _textPrimary)),
        backgroundColor: success ? const Color(0xFF22814F) : _bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 52),

              // ── Ícono + título ──
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Report Valledupar',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Valledupar · Reportes ciudadanos',
                style: TextStyle(color: _textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 36),

              // ── Tarjeta del formulario ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nombre
                    _label('Nombre completo'),
                    const SizedBox(height: 8),
                    _field(
                      controller: _nombreCtrl,
                      hint: 'Tu nombre',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 18),

                    // Correo
                    _label('Correo electrónico'),
                    const SizedBox(height: 8),
                    _field(
                      controller: _correoCtrl,
                      hint: 'ejemplo@correo.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    // Contraseña
                    _label('Contraseña'),
                    const SizedBox(height: 8),
                    _field(
                      controller: _contrasenaCtrl,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_verContrasena,
                      suffix: IconButton(
                        icon: Icon(
                          _verContrasena
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _verContrasena = !_verContrasena),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botón Registrarse
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _registrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _accent.withOpacity(0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: _cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Registrarse'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Ya tengo cuenta ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes cuenta? ',
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary, fontSize: 15),
      cursorColor: _accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: _textSecondary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _bgField,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      ),
    );
  }
}