import 'entidad_base.dart';

class ComunaModel extends EntidadBase {
  final String nombreComuna;

  ComunaModel({
    super.id,
    super.createdAt,
    required this.nombreComuna,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'nombre_comuna': nombreComuna,
    };
  }

  factory ComunaModel.fromJson(Map<String, dynamic> json) {
    return ComunaModel(
      id: json['id'],
      nombreComuna: json['nombre_comuna'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
}