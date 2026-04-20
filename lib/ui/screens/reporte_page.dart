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

      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Bienvenido ${widget.nombreUsuario}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: cargando ? null : analizarIA,
              icon: const Icon(Icons.smart_toy),
              label: const Text("Analizar con IA"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: comentarioController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Comentario",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              value: categoriaId,
              decoration: const InputDecoration(
                labelText: "Categoría",
                border: OutlineInputBorder(),
              ),
              items: categorias.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.nombre));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  categoriaId = value;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              value: autoridadId,
              decoration: const InputDecoration(
                labelText: "Autoridad",
                border: OutlineInputBorder(),
              ),
              items: autoridades.map((a) {
                return DropdownMenuItem(value: a.id, child: Text(a.nombre));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  autoridadId = value;
                });
              },
            ),

            const SizedBox(height: 20),

            if (imagen != null)
              Image.file(imagen!, height: 180, fit: BoxFit.cover),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: seleccionarImagen,
              icon: const Icon(Icons.image),
              label: const Text("Seleccionar Imagen"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: cargando ? null : guardarReporte,
              child: cargando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Guardar Reporte"),
            ),
          ],
        ),
      ),
    );
  }
}
