import 'package:flutter/material.dart';
import 'dart:ui';
import '../../services/auth_service.dart';
import 'admin_login_screen.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _iniciarSesionGoogle() async {
    setState(() {
      _isLoading = true;
    });

    await _authService.signInWithGoogle();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // CAPA 1: FONDO (IMAGEN DEL PARQUE)
          // ==========================================
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo_parque.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ==========================================
          // CAPA 2: FILTRO OSCURO (OVERLAY)
          // ==========================================
          Container(
            color: Colors.black.withOpacity(
              0.4,
            ), // Lo bajé a 0.4 para que se vea más el parque
          ),

          // ==========================================
          // CAPA 3: CONTENIDO
          // ==========================================
          SafeArea(
            child: Column(
              children: [
                // --- BOTÓN ACCESO ADMIN (Se mantiene intacto) ---
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLoginScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Acceso Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(), // Empuja la "caja" hacia el centro/abajo
                // --- CAJA TRANSPARENTE CON TEXTOS Y BOTÓN ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  // ClipRRect es necesario para que el desenfoque no se salga de los bordes redondeados
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10.0,
                        sigmaY: 10.0,
                      ), // Efecto de cristal (Glassmorphism)
                      child: Container(
                        padding: const EdgeInsets.all(30.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.15,
                          ), // Blanco semi-transparente
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              0.2,
                            ), // Borde sutil brillante
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // Para que la caja se ajuste a su contenido
                          children: [
                            // --- MENSAJE DE BIENVENIDA ---
                            const Text(
                              'Reportes de Parques\nVillavicencio',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.2, // Espaciado entre las dos líneas
                              ),
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              'Cuidemos nuestra ciudad juntos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // --- BOTÓN DE GOOGLE ---
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation:
                                      0, // Quitamos la sombra para que se vea más plano contra el cristal
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _iniciarSesionGoogle,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.green,
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.g_mobiledata,
                                            size: 40,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Ingresar con Google',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Un poco de espacio extra al fondo
              ],
            ),
          ),
        ],
      ),
    );
  }
}
