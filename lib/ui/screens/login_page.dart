import 'package:flutter/material.dart';
import 'package:ojociudadano/controllers/administrador/autoridad_login_controller.dart';
import 'package:ojociudadano/controllers/login_controller.dart';
import 'package:ojociudadano/ui/screens/Administrador/afinia/afinia_page.dart';
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

  void iniciarSesion() async {
    setState(() => cargando = true);

    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    // 🔴 Validación básica
    if (correo.isEmpty || password.isEmpty) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    try {
      // 🔹 1. Intentar login como autoridad
      final autoridad =
          await autoridadLoginController.login(correo, password);

      if (!mounted) return;

      if (autoridad != null) {
        // UNA SOLA PANTALLA PARA TODAS
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReportesAutoridadPage(
              autoridadId: autoridad.id,
              titulo: autoridad.nombre, // dinámico
            ),
          ),
        );
        return;
      }

      // 🔹 2. Usuario normal
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Correo o contraseña incorrectos"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => cargando = false);
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const Icon(Icons.location_city,
                    size: 70, color: Color(0xFF2D6CDF)),

                const SizedBox(height: 10),

                const Text(
                  "Report Valledupar",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: correoController,
                        decoration: _input("Correo", Icons.email),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: _input("Contraseña", Icons.lock),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: cargando ? null : iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D6CDF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: cargando
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Ingresar",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistroPage(),
                      ),
                    );
                  },
                  child: const Text("¿No tienes cuenta? Regístrate"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String text, IconData icon) {
    return InputDecoration(
      hintText: text,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}