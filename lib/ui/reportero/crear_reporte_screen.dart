import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrearReporteScreen extends StatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controladores de estado para los selectores
  String? _parqueSeleccionado;
  String? _tipoDanoSeleccionado;

  // Controladores de texto
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _parqueOtroController = TextEditingController();
  final TextEditingController _danoOtroController = TextEditingController();

  // Manejo de la imagen
  File? _imagen;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Listas de opciones
  final List<String> _parques = [
    'Parque Los Fundadores',
    'Parque de la Vida',
    'Parque Infantil',
    'Parque Guayuriba',
    'Otro',
  ];
  final List<String> _tiposDano = [
    'Mobiliario roto',
    'Iluminación',
    'Basura/Escombros',
    'Vegetación descuidada',
    'Juegos infantiles',
    'Otro',
  ];

  Future<void> _seleccionarImagen() async {
    final XFile? imagenSeleccionada = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imagenSeleccionada != null) {
      setState(() {
        _imagen = File(imagenSeleccionada.path);
      });
    }
  }

  Future<void> _enviarReporte() async {
    if (_formKey.currentState!.validate()) {
      if (_imagen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, adjunta una foto del daño.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // 1. Preparamos los textos finales
        final String danoFinal = _tipoDanoSeleccionado == 'Otro'
            ? _danoOtroController.text.trim()
            : _tipoDanoSeleccionado!;
        final String descripcionFinal = _descripcionController.text.trim();

        // Obtenemos el ID del ciudadano que inició sesión
        final String usuarioId = _supabase.auth.currentUser!.id;

        // 2. SUBIR LA IMAGEN A SUPABASE STORAGE
        final fileExtension = _imagen!.path.split('.').last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        final imagePath = '$usuarioId/$fileName';

        await _supabase.storage
            .from('evidencias_reportes')
            .upload(imagePath, _imagen!);

        // 3. OBTENER EL ENLACE DE LA IMAGEN
        final String imageUrl = _supabase.storage
            .from('evidencias_reportes')
            .getPublicUrl(imagePath);

        // 4. GUARDAR LOS DATOS EN LA TABLA 'reporte'
        await _supabase.from('reporte').insert({
          'parque_id': 1,
          'reportero_id': usuarioId,
          'descripcion': descripcionFinal,
          'tipo_danio': danoFinal,
          'imagen_url': imageUrl,
          'estado': 'reportado',
        });

        // Si todo sale bien, mostramos mensaje de éxito y regresamos al menú
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Reporte enviado con éxito!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error de Supabase: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al enviar el reporte. Revisa tu conexión.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _parqueOtroController.dispose();
    _danoOtroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nuevo Reporte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ayúdanos a mejorar Villavicencio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // --- CAMPO: SELECCIÓN DE PARQUE ---
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '¿En qué parque estás?',
                        prefixIcon: const Icon(Icons.park, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _parques.map((String parque) {
                        return DropdownMenuItem(
                          value: parque,
                          child: Text(parque),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _parqueSeleccionado = value;
                          if (value != 'Otro') _parqueOtroController.clear();
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Selecciona un parque' : null,
                    ),

                    // --- CAMPO INTELIGENTE: ESCRIBIR OTRO PARQUE ---
                    if (_parqueSeleccionado == 'Otro') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _parqueOtroController,
                        decoration: InputDecoration(
                          labelText: 'Escribe el nombre del parque',
                          prefixIcon: const Icon(
                            Icons.edit_location,
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.green.withOpacity(0.05),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Debes escribir el nombre del parque'
                            : null,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // --- CAMPO: TIPO DE DAÑO ---
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Tipo de daño',
                        prefixIcon: const Icon(
                          Icons.report_problem,
                          color: Colors.orange,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _tiposDano.map((String dano) {
                        return DropdownMenuItem(value: dano, child: Text(dano));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoDanoSeleccionado = value;
                          if (value != 'Otro') _danoOtroController.clear();
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Selecciona el tipo de daño' : null,
                    ),

                    // --- CAMPO INTELIGENTE: ESCRIBIR OTRO DAÑO ---
                    if (_tipoDanoSeleccionado == 'Otro') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _danoOtroController,
                        decoration: InputDecoration(
                          labelText: 'Especifica el tipo de daño',
                          prefixIcon: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.orange.withOpacity(0.05),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Debes especificar el daño' : null,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // --- CAMPO: DESCRIPCIÓN ---
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción detallada',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.description, color: Colors.green),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Escribe una breve descripción'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // --- CAMPO: FOTO DEL DAÑO ---
                    Text(
                      'Evidencia fotográfica',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _seleccionarImagen,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.5),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _imagen != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _imagen!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Toca para subir una foto',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- BOTÓN: ENVIAR REPORTE ---
                    ElevatedButton(
                      onPressed: _enviarReporte,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
