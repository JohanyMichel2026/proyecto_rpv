import 'entidad_base.dart';

class UsuarioModel extends EntidadBase {
  final String nombre;
  final String rol; // 'admin' o 'reportero'
  final String? avatarUrl;

  UsuarioModel({
    required super.id, // El UUID de la cuenta
    super.createdAt,
    required this.nombre,
    required this.rol,
    this.avatarUrl,
  });

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'rol': rol, 'avatar_url': avatarUrl};
  }

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nombre: json['nombre'],
      rol: json['rol'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
