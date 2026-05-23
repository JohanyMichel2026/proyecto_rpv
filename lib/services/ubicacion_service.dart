import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parque_model.dart';

class UbicacionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // 1. LISTA DE COMUNAS ORDENADAS POR CANTIDAD DE REPORTES
  // (De más reportes a menos reportes)
  // ============================================================
  Future<List<Map<String, dynamic>>> obtenerComunasConRanking() async {
    try {
      // Esta consulta hace un JOIN implícito y cuenta cuántos reportes
      // tiene cada comuna a través de sus parques.
      final response = await _supabase.from('comunas').select('''
            id,
            nombre_comuna,
            parques (
              reportes (count)
            )
          ''');

      // Procesamos la respuesta para sumar los conteos y ordenar
      List<Map<String, dynamic>> ranking = (response as List).map((comuna) {
        int totalReportes = 0;
        final parques = comuna['parques'] as List;

        for (var parque in parques) {
          final conteo = (parque['reportes'] as List).first['count'] as int;
          totalReportes += conteo;
        }

        return {
          'id': comuna['id'],
          'nombre': comuna['nombre_comuna'],
          'total': totalReportes,
        };
      }).toList();

      // Ordenamos de mayor a menor según el 'total'
      ranking.sort((a, b) => b['total'].compareTo(a['total']));

      return ranking;
    } catch (e) {
      print("Error al obtener ranking de comunas: $e");
      return [];
    }
  }

  // ============================================================
  // 2. LISTA DE PARQUES SEGÚN LA COMUNA SELECCIONADA
  // ============================================================
  Future<List<ParqueModel>> obtenerParquesPorComuna(int comunaId) async {
    try {
      final response = await _supabase
          .from('parques')
          .select()
          .eq('comuna_id', comunaId)
          .order('nombre', ascending: true);

      return (response as List)
          .map((json) => ParqueModel.fromJson(json))
          .toList();
    } catch (e) {
      print("Error al obtener parques: $e");
      return [];
    }
  }
}
