import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Obtener el perfil actual
  Future<UsuarioModel?> getUsuarioActual() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UsuarioModel.fromJson(data);
    } catch (e) {
      print("Error al obtener perfil: $e");
      return null;
    }
  }

  // 2. LOGIN CON GOOGLE (Nativo de Supabase)
  Future<void> signInWithGoogle() async {
    try {
      // Esto abrirá el navegador de forma segura.
      // Supabase se encarga de todo el proceso de tokens por ti.
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'apprpv://login-callback', // <-- ¡AQUÍ SE AGREGA LA LÍNEA CLAVE!
      );
    } catch (e) {
      print("Error en Google Auth: $e");
    }
  }

  // 3. LOGIN COMO ADMINISTRADOR
  Future<void> signInAsAdmin({
    required String email,
    required String password,
  }) async {
    await signOut(); // Cerramos cualquier sesión previa

    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Validamos si tiene rol de admin
    final perfil = await getUsuarioActual();
    if (perfil == null || perfil.rol != 'admin') {
      await signOut();
      throw 'Acceso denegado: No tienes permisos de administrador.';
    }
  }

  // 4. CERRAR SESIÓN
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
