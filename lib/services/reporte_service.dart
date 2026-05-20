import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reporte_model.dart';

class ReporteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // 1. SUBIR IMAGEN DEL DAÑO AL STORAGE
  // ==========================================
  Future<String?> subirImagen(File imagen, String extension) async {
    try {
      // Generamos un nombre único basado en la fecha y hora exacta
      final nombreArchivo =
          'dano_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Subimos el archivo al bucket que creaste
      await _supabase.storage
          .from('reportes_imagenes')
          .upload(nombreArchivo, imagen);

      // Obtenemos y retornamos la URL pública para guardarla en la base de datos
      final urlPublica = _supabase.storage
          .from('reportes_imagenes')
          .getPublicUrl(nombreArchivo);

      return urlPublica;
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }

  // ==========================================
  // 2. CREAR UN NUEVO REPORTE (Reportero)
  // ==========================================
  Future<bool> crearReporte(ReporteModel reporte) async {
    try {
      // Por seguridad, obtenemos el ID del usuario directamente de la sesión activa
      final userId = _supabase.auth.currentUser!.id;

      // Usamos el método copyWith (POO) para inyectar el ID del reportero
      // antes de enviarlo a la base de datos
      final reporteFinal = reporte.copyWith(
        reporteroId: userId,
        estado: 'reportado', // Siempre inicia así por defecto
      );

      await _supabase.from('reportes').insert(reporteFinal.toMap());
      return true; // Éxito
    } catch (e) {
      print("Error al crear reporte: $e");
      return false; // Fallo
    }
  }

  // ==========================================
  // 3. OBTENER REPORTES (Para el Dashboard del Admin)
  // ==========================================
  Future<List<ReporteModel>> obtenerTodosLosReportes() async {
    try {
      // Traemos los reportes ordenados del más reciente al más antiguo
      final response = await _supabase
          .from('reportes')
          .select()
          .order('created_at', ascending: false);

      // Transformamos la lista de JSONs a una lista de Objetos ReporteModel
      return (response as List)
          .map((json) => ReporteModel.fromJson(json))
          .toList();
    } catch (e) {
      print("Error al obtener reportes: $e");
      return [];
    }
  }

  // ==========================================
  // 4. ACTUALIZAR ESTADO DEL REPORTE (Admin)
  // ==========================================
  Future<bool> actualizarEstado(String reporteId, String nuevoEstado) async {
    try {
      await _supabase
          .from('reportes')
          .update({'estado': nuevoEstado})
          .eq('id', reporteId);
      return true;
    } catch (e) {
      print("Error al actualizar estado: $e");
      return false;
    }
  }
}
