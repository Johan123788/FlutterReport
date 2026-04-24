import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:ojociudadano/services/ia_service.dart';
import 'package:ojociudadano/services/cloudinary_service.dart';

import 'package:ojociudadano/controllers/reporte_controller.dart';
import 'package:ojociudadano/controllers/categoria_controller.dart';
import 'package:ojociudadano/controllers/autoridad_controller.dart';

import 'package:ojociudadano/models/categoria.dart';
import 'package:ojociudadano/models/autoridad.dart';

class CrearReportePage extends StatefulWidget {
  final int usuarioId;
  final String nombreUsuario;

  const CrearReportePage({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
  });

  @override
  State<CrearReportePage> createState() => _CrearReportePageState();
}

class _CrearReportePageState extends State<CrearReportePage> {
  final descripcionController = TextEditingController();
  final comentarioController = TextEditingController();

  final IaService iaService = IaService();
  final ReporteController reporteController = ReporteController();
  final CategoriaController categoriaController = CategoriaController();
  final AutoridadController autoridadController = AutoridadController();

  List<Categoria> categorias = [];
  List<Autoridad> autoridades = [];

  int? categoriaId;
  int? autoridadId;

  File? imagen;

  bool cargando = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    categorias = await categoriaController.obtenerCategorias();
    autoridades = await autoridadController.obtenerAutoridades();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();

    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);

    if (photo == null) return;

    imagen = File(photo.path);

    setState(() {});
  }

  Future<Position?> obtenerUbicacion() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el GPS está activo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Activa el GPS")));
      return null;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permisos de ubicación denegados")),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> analizarIA() async {
    // 1. VALIDACIÓN: si el usuario no escribió nada, no se puede analizar
    if (descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe una descripción primero")),
      );
      return; // detiene la ejecución
    }

    try {
      // 2. ACTIVA ESTADO DE CARGA (UI puede mostrar loading)
      setState(() => cargando = true);

      // 3. ENVÍA LA DESCRIPCIÓN A LA IA (backend)
      //    aquí se hace la llamada HTTP y se espera respuesta
      final resultado = await iaService.analizarTexto(
        descripcionController.text,
      );

      // 4. IMPRIME RESPUESTA DE LA IA (debug)
      print(resultado);

      // ============================
      // 5. DESCRIPCIÓN MEJORADA POR IA
      // ============================
      // La IA devuelve una descripción más clara o formal
      descripcionController.text =
          resultado["descripcion"] ?? descripcionController.text;

      // ============================
      // 6. PROCESO DE CATEGORÍA
      // ============================

      // La IA devuelve el nombre de la categoría (texto)
      final categoriaDetectada = resultado["categoria"]
          .toString()
          .toLowerCase();

      // Se busca en la lista de categorías de la BD
      final categoriaEncontrada = categorias.firstWhere(
        (c) => c.nombre.toLowerCase() == categoriaDetectada,
        orElse: () => Categoria(id: 0, nombre: ""),
      );

      // Si existe coincidencia, guardamos el ID real de la BD
      if (categoriaEncontrada.id != 0) {
        categoriaId = categoriaEncontrada.id;
      }

      // ============================
      // 7. PROCESO DE AUTORIDAD
      // ============================

      // La IA devuelve el nombre de la autoridad (texto)
      final autoridadDetectada = resultado["autoridad"]
          .toString()
          .toLowerCase();

      // Se busca en la lista de autoridades de la BD
      final autoridadEncontrada = autoridades.firstWhere(
        (a) => a.nombre.toLowerCase() == autoridadDetectada,
        orElse: () => Autoridad(id: 0, nombre: ""),
      );

      // Si existe coincidencia, guardamos el ID real
      if (autoridadEncontrada.id != 0) {
        autoridadId = autoridadEncontrada.id;
      }

      // ============================
      // 8. ACTUALIZA LA INTERFAZ (UI)
      // ============================
      //  REFRESCA LA PANTALLA
      setState(() {});
    } catch (e) {
      // 9. SI ALGO FALLA CON LA IA O JSON
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("ERROR IA: $e")));
    }

    // 10. DESACTIVA EL LOADING AL FINAL
    setState(() => cargando = false);
  }

  Future<void> guardarReporte() async {
    if (descripcionController.text.isEmpty ||
        comentarioController.text.isEmpty ||
        categoriaId == null ||
        autoridadId == null ||
        imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    try {
      setState(() => cargando = true);

      final posicion = await obtenerUbicacion();

      if (posicion == null) {
        setState(() => cargando = false);
        return;
      }
      final evidenciaUrl = await CloudinaryService().uploadImage(imagen!);

      if (evidenciaUrl == null || evidenciaUrl.isEmpty) {
        throw Exception("No se pudo subir imagen");
      }

      await reporteController.crearReporte(
        descripcionController.text,
        comentarioController.text,
        evidenciaUrl,
        widget.usuarioId,
        categoriaId!,
        autoridadId!,
        posicion.longitude,
        posicion.latitude,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reporte guardado correctamente")),
      );

      descripcionController.clear();
      comentarioController.clear();

      setState(() {
        categoriaId = null;
        autoridadId = null;
        imagen = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => cargando = false);
  }

  @override
  void dispose() {
    descripcionController.dispose();
    comentarioController.dispose();
    super.dispose();
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Reporte"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Crear reporte",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              "Describe el problema y nosotros te ayudamos",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            // 🧠 DESCRIPCIÓN + IA
            _card(
              child: Column(
                children: [
                  TextField(
                    controller: descripcionController,
                    maxLines: 3,
                    decoration: _inputStyle("Describe el problema"),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: cargando ? null : analizarIA,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Mejorar con IA"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6CDF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 💬 COMENTARIO
            _card(
              child: TextField(
                controller: comentarioController,
                maxLines: 2,
                decoration: _inputStyle("Comentario adicional"),
              ),
            ),

            const SizedBox(height: 15),

            // 📂 CATEGORÍA Y AUTORIDAD
            _card(
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: categoriaId,
                    decoration: _inputStyle("Categoría"),
                    items: categorias.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => categoriaId = value);
                    },
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<int>(
                    value: autoridadId,
                    decoration: _inputStyle("Autoridad"),
                    items: autoridades.map((a) {
                      return DropdownMenuItem(
                        value: a.id,
                        child: Text(a.nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => autoridadId = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 📸 IMAGEN
            _card(
              child: Column(
                children: [
                  if (imagen != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imagen!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: seleccionarImagen,
                    icon: const Icon(Icons.image),
                    label: const Text("Agregar imagen"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🚀 BOTÓN FINAL
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: cargando ? null : guardarReporte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6CDF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Enviar reporte"),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String placeholder) {
    return InputDecoration(
      hintText: placeholder,
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }
}
