import 'package:flutter/material.dart';

// Cambiamos la ruta para que busque correctamente en la carpeta services
import '../../services/auth_service.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  final AuthService _authService = AuthService();
  int _indiceActual = 0; // Controla qué pestaña está activa

  // --- DATOS DE PRUEBA: REPORTES ---
  final List<Map<String, dynamic>> _reportesPrueba = [
    {
      'id': '1',
      'parque': 'Parque Los Fundadores',
      'dano': 'Mobiliario roto',
      'estado': 'reportado',
      'fecha': '22/05/2026',
    },
    {
      'id': '2',
      'parque': 'Parque de la Vida',
      'dano': 'Iluminación',
      'estado': 'procesando',
      'fecha': '18/05/2026',
    },
    {
      'id': '3',
      'parque': 'Parque Guayuriba',
      'dano': 'Vegetación descuidada',
      'estado': 'en ejecucion',
      'fecha': '15/05/2026',
    },
  ];

  // --- DATOS DE PRUEBA: RANKING COMUNAS ---
  final List<Map<String, dynamic>> _comunasPrueba = [
    {'nombre': 'Comuna 1', 'reportesActivos': 15},
    {'nombre': 'Comuna 5', 'reportesActivos': 8},
    {'nombre': 'Comuna 2', 'reportesActivos': 4},
    {'nombre': 'Comuna 7', 'reportesActivos': 1},
  ];

  Future<void> _cerrarSesion() async {
    await _authService.signOut();
  }

  // Cambia el estado del reporte visualmente (Pronto lo conectaremos a la BD)
  void _cambiarEstadoReporte(int index, String nuevoEstado) {
    setState(() {
      _reportesPrueba[index]['estado'] = nuevoEstado;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado actualizado a: $nuevoEstado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lista de pantallas para la navegación
    final List<Widget> pantallas = [
      _construirVistaGestion(),
      _construirVistaRanking(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Panel de Control RPV',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800], // Verde más oscuro para el admin
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: pantallas[_indiceActual],

      // --- BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) => setState(() => _indiceActual = index),
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Gestión'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Ranking Comunas',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PESTAÑA 1: GESTIÓN DE REPORTES
  // ==========================================
  Widget _construirVistaGestion() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reportesPrueba.length,
      itemBuilder: (context, index) {
        final reporte = _reportesPrueba[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reporte['parque'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Daño: ${reporte['dano']}',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                Text(
                  'Fecha: ${reporte['fecha']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estado actual:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // --- DROPDOWN PARA CAMBIAR EL ESTADO ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: reporte['estado'],
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.green[800],
                        ),
                        items:
                            [
                                  'reportado',
                                  'procesando',
                                  'en ejecucion',
                                  'completado',
                                ]
                                .map(
                                  (estado) => DropdownMenuItem(
                                    value: estado,
                                    child: Text(
                                      estado.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.green[800],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (nuevoEstado) {
                          if (nuevoEstado != null) {
                            _cambiarEstadoReporte(index, nuevoEstado);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // PESTAÑA 2: RANKING DE COMUNAS
  // ==========================================
  Widget _construirVistaRanking() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.green[800],
          child: const Text(
            'Zonas con más reportes activos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _comunasPrueba.length,
            itemBuilder: (context, index) {
              final comuna = _comunasPrueba[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: index == 0
                      ? Colors.red[100]
                      : Colors.green[100],
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      color: index == 0 ? Colors.red[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  comuna['nombre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: Chip(
                  label: Text('${comuna['reportesActivos']} Reportes'),
                  backgroundColor: index == 0
                      ? Colors.red[50]
                      : Colors.grey[200],
                  labelStyle: TextStyle(
                    color: index == 0 ? Colors.red[800] : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
