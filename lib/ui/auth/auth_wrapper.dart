import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'google_login_screen.dart';
import '../reportero/home_reportero.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSubscription;

  bool _isLoading = true;
  Widget _pantallaDestino = const GoogleLoginScreen();

  @override
  void initState() {
    super.initState();
    _configurarEscuchaDeSesion();
  }

  void _configurarEscuchaDeSesion() {
    // Escuchamos cualquier cambio en la sesión (cuando inician o cierran sesión)
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      final Session? session = data.session;

      if (session == null) {
        // No hay sesión activa, mandar al Login
        if (mounted) {
          setState(() {
            _pantallaDestino = const GoogleLoginScreen();
            _isLoading = false;
          });
        }
      } else {
        // Hay sesión activa. Vamos a revisar qué rol tiene en la tabla 'profiles'
        try {
          final userId = session.user.id;
          final response = await _supabase
              .from('profiles')
              .select('rol')
              .eq('id', userId)
              .single();

          final String rol = response['rol'] ?? 'reportero';

          if (mounted) {
            setState(() {
              if (rol == 'admin') {
                // TODO: Reemplazar con la pantalla real del Dashboard del Administrador
                _pantallaDestino = const Scaffold(
                  body: Center(
                    child: Text(
                      'Dashboard Admin\n(En construcción)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                _pantallaDestino = const HomeReportero();
              }
              _isLoading = false;
            });
          }
        } catch (e) {
          // Si ocurre un error (ej: el trigger de la base de datos aún no termina de
          // crear el perfil en el primer milisegundo), lo mandamos a la vista de
          // reportero por defecto para no bloquear la app.
          if (mounted) {
            setState(() {
              _pantallaDestino = const HomeReportero();
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // Importante para la memoria de la app: apagar el "escucha" cuando se cierra el widget
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mientras averigua quién es el usuario, mostramos una pantalla de carga
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    // Retorna la pantalla que decidió el semáforo (Login, Admin o Reportero)
    return _pantallaDestino;
  }
}
