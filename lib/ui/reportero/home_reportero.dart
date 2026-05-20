import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

class HomeReportero extends StatefulWidget {
  const HomeReportero({super.key});

  @override
  State<HomeReportero> createState() => _HomeReporteroState();
}

class _HomeReporteroState extends State<HomeReportero> {
  final AuthService _authService = AuthService();
  String _nombreUsuario = 'Ciudadano';

  @override
  void initState() {
    super.initState();
    _obtenerDatosUsuario();
  }

  // Extraemos el nombre directamente de los metadatos de Google
  void _obtenerDatosUsuario() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.userMetadata != null) {
      setState(() {
        // Google guarda el nombre completo en 'full_name'
        _nombreUsuario = user.userMetadata!['full_name'] ?? 'Ciudadano';
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await _authService.signOut();
    // Nota: El AuthWrapper detectará el cierre de sesión y lo regresará al Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .grey[100], // Un fondo blanco grisáceo para que resalten las tarjetas
      appBar: AppBar(
        title: const Text(
          'Portal Ciudadano',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        // ¡Se ha eliminado el botón de "Acceso Admin" de aquí!
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SALUDO PERSONALIZADO ---
              Text(
                '¡Hola, $_nombreUsuario!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Qué parque de Villavicencio te gustaría reportar hoy?',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // --- BOTÓN PRINCIPAL: NUEVO REPORTE ---
              _construirTarjetaAccion(
                context: context,
                titulo: 'Nuevo Reporte',
                subtitulo: 'Sube una foto y describe el daño',
                icono: Icons.add_a_photo,
                colorFondo: Colors.green,
                colorTexto: Colors.white,
                alPresionar: () {
                  // TODO: Navegar a la pantalla de crear reporte
                  print('Navegar a Crear Reporte');
                },
              ),

              const SizedBox(height: 16),

              // --- BOTONES SECUNDARIOS (Fila) ---
              Row(
                children: [
                  Expanded(
                    child: _construirTarjetaAccion(
                      context: context,
                      titulo: 'Mis Reportes',
                      subtitulo: 'Ver historial',
                      icono: Icons.list_alt,
                      colorFondo: Colors.white,
                      colorTexto: Colors.black87,
                      alPresionar: () {
                        // TODO: Navegar a la lista de reportes
                        print('Navegar a Mis Reportes');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _construirTarjetaAccion(
                      context: context,
                      titulo: 'Mi Perfil',
                      subtitulo: 'Mis datos',
                      icono: Icons.person_outline,
                      colorFondo: Colors.white,
                      colorTexto: Colors.black87,
                      alPresionar: () {
                        // TODO: Navegar al perfil
                        print('Navegar a Mi Perfil');
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // --- BOTÓN DE CERRAR SESIÓN ---
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MÉTODO AYUDANTE PARA CONSTRUIR TARJETAS
  // ============================================================
  Widget _construirTarjetaAccion({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorFondo,
    required Color colorTexto,
    required VoidCallback alPresionar,
  }) {
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 36, color: colorTexto),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorTexto,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              style: TextStyle(
                fontSize: 14,
                color: colorTexto.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
