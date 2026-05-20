import 'entidad_base.dart';

class ParqueModel extends EntidadBase {
  final String nombre;
  final String direccion;
  final int comunaId;
  final double? latitud;
  final double? longitud;

  ParqueModel({
    super.id, // ID autogenerado
    super.createdAt,
    required this.nombre,
    required this.direccion,
    required this.comunaId,
    this.latitud,
    this.longitud,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'comuna_id': comunaId,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  factory ParqueModel.fromJson(Map<String, dynamic> json) {
    return ParqueModel(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      comunaId: json['comuna_id'],
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
