import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilReportero extends StatefulWidget {
  const PerfilReportero({super.key});

  @override
  State<PerfilReportero> createState() => _PerfilReporteroState();
}

class _PerfilReporteroState extends State<PerfilReportero> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  String _nombre = 'Cargando...';
  String _correo = 'Cargando...';
  String _rol = 'Cargando...';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  Future<void> _cargarDatosPerfil() async {
    final user = _supabase.auth.currentUser;

    if (user != null) {
      // 1. Extraemos los datos que nos regala Google desde la sesión
      _correo = user.email ?? 'Sin correo';
      _nombre = user.userMetadata?['full_name'] ?? 'Ciudadano de Villavicencio';
      _avatarUrl = user
          .userMetadata?['avatar_url']; // URL de la foto de perfil de Google

      try {
        // 2. Consultamos la tabla 'profiles' en la BD para traer el Rol asignado
        final data = await _supabase
            .from('profiles')
            .select('rol')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _rol = data['rol'] ?? 'reportero';
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _rol = 'reportero'; // Rol por defecto si falla la petición
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // --- AVATAR / FOTO DE PERFIL ---
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.green[100],
                        // Si Google nos da una foto, la renderiza; si no, pone un icono de usuario
                        backgroundImage: _avatarUrl != null
                            ? NetworkImage(_avatarUrl!)
                            : null,
                        child: _avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.green,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- NOMBRE DEL CIUDADANO ---
                  Text(
                    _nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- TARJETA DE DETALLES DEL PERFIL ---
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      child: Column(
                        children: [
                          _construirFilaInfo(
                            icono: Icons.email_outlined,
                            titulo: 'Correo electrónico',
                            valor: _correo,
                          ),
                          const Divider(height: 1, indent: 55, endIndent: 20),
                          _construirFilaInfo(
                            icono: Icons.badge_outlined,
                            titulo: 'Rol de usuario',
                            // Pasamos a mayúscula la primera letra para que se vea más estético
                            valor: _rol.isNotEmpty
                                ? '${_rol[0].toUpperCase()}${_rol.substring(1)}'
                                : '',
                          ),
                          const Divider(height: 1, indent: 55, endIndent: 20),
                          _construirFilaInfo(
                            icono: Icons.location_city_outlined,
                            titulo: 'Municipio',
                            valor: 'Villavicencio, Meta',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Método ayudante para estructurar las filas de información de manera uniforme
  Widget _construirFilaInfo({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: Colors.green),
      ),
      title: Text(
        titulo,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
