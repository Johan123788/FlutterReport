import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/administrador/autoridad_login_controller.dart';
import 'package:ojociudadano/controllers/login_controller.dart';

import 'package:ojociudadano/ui/screens/Administrador/dashboard_page.dart';
import 'package:ojociudadano/ui/screens/Usuario/inicio_page.dart';
import 'package:ojociudadano/ui/screens/registro_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginController loginController = LoginController();
  final AutoridadLoginController autoridadLoginController =
      AutoridadLoginController();

  bool cargando = false;
  bool _verPassword = false;

  void iniciarSesion() async {
    setState(() => cargando = true);

    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      setState(() => cargando = false);
      _snack("Completa todos los campos");
      return;
    }

    try {
      // 1. Intentar login como autoridad
      final autoridad = await autoridadLoginController.login(correo, password);

      if (!mounted) return;

      if (autoridad != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboardPage( // ✅ NAVEGA AL DASHBOARD
              autoridadId: autoridad.id,
              titulo: autoridad.nombre,
            ),
          ),
        );
        return;
      }

      // 2. Usuario normal
      final usuario = await loginController.login(correo, password);

      if (!mounted) return;

      if (usuario != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              usuarioId: usuario.id,
              nombreUsuario: usuario.nombre,
            ),
          ),
        );
      } else {
        _snack("Correo o contraseña incorrectos");
      }
    } catch (e) {
      _snack("Error: $e");
    }

    setState(() => cargando = false);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF161B22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              // ── Logo / ícono ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Ojo Ciudadano",
                style: TextStyle(
                  color: Color(0xFFF0F6FC),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Valledupar · Reportes ciudadanos",
                style: TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 36),

              // ── Formulario ──
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Iniciar sesión",
                      style: TextStyle(
                        color: Color(0xFFF0F6FC),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Correo
                    _buildLabel("Correo electrónico"),
                    const SizedBox(height: 6),
                    _buildInput(
                      controller: correoController,
                      hint: "ejemplo@correo.com",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    // Contraseña
                    _buildLabel("Contraseña"),
                    const SizedBox(height: 6),
                    _buildInput(
                      controller: passwordController,
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      obscure: !_verPassword,
                      suffix: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF8B949E),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _verPassword = !_verPassword),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón ingresar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: cargando ? null : iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          disabledBackgroundColor:
                              const Color(0xFF3B82F6).withOpacity(0.4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: cargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Ingresar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿No tienes cuenta?",
                    style: TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegistroPage()),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF60A5FA),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: const Text(
                      "Regístrate",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers de UI ──────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8B949E),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF484F58), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF8B949E), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF21262D),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
      ),
    );
  }
}