import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MisReportesScreen extends StatefulWidget {
  const MisReportesScreen({super.key});

  @override
  State<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends State<MisReportesScreen> {
  final _supabase = Supabase.instance.client;
  final bool _isLoading = false;

  // TODO: Más adelante esta lista vendrá vacía y se llenará consultando a Supabase
  // Por ahora usamos datos de prueba (Mock Data) para diseñar la interfaz
  final List<Map<String, dynamic>> _reportesPrueba = [
    {
      'parque': 'Parque Los Fundadores',
      'dano': 'Mobiliario roto',
      'fecha': '22/05/2026',
      'estado': 'reportado',
    },
    {
      'parque': 'Parque de la Vida',
      'dano': 'Iluminación',
      'fecha': '18/05/2026',
      'estado': 'procesando',
    },
    {
      'parque': 'Parque Infantil',
      'dano': 'Basura/Escombros',
      'fecha': '10/05/2026',
      'estado': 'completado',
    },
  ];

  // Método para darle un color diferente a la etiqueta según el estado
  Color _obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'reportado':
        return Colors.orange; // Naranja para lo recién subido
      case 'procesando':
      case 'en ejecucion':
        return Colors.blue; // Azul para lo que ya están revisando/arreglando
      case 'completado':
        return Colors.green; // Verde para lo solucionado
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Mis Reportes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _reportesPrueba.isEmpty
          ? _construirPantallaVacia()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reportesPrueba.length,
              itemBuilder: (context, index) {
                final reporte = _reportesPrueba[index];
                return _construirTarjetaReporte(reporte);
              },
            ),
    );
  }

  // Diseño de la tarjeta individual de cada reporte
  Widget _construirTarjetaReporte(Map<String, dynamic> reporte) {
    final colorEstado = _obtenerColorEstado(reporte['estado']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    reporte['parque'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Etiqueta (Badge) de Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorEstado, width: 1),
                  ),
                  child: Text(
                    reporte['estado'].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorEstado,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.report_problem, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  reporte['dano'],
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Reportado el: ${reporte['fecha']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Diseño por si el ciudadano aún no ha hecho ningún reporte
  Widget _construirPantallaVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no has hecho ningún reporte',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus reportes aparecerán aquí',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
