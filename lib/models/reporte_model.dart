import 'entidad_base.dart';

class ReporteModel extends EntidadBase {
  final int parqueId;
  final String? reporteroId;
  final String descripcion;
  final String tipoDanio;
  final String? imagenUrl;
  final String estado;

  ReporteModel({
    super.id,
    super.createdAt,
    required this.parqueId,
    this.reporteroId,
    required this.descripcion,
    required this.tipoDanio,
    this.imagenUrl,
    this.estado = 'reportado',
  });

  // Método FACTORY para crear el objeto desde un JSON
  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    return ReporteModel(
      id: json['id'],
      parqueId: json['parque_id'],
      reporteroId: json['reportero_id'],
      descripcion: json['descripcion'],
      tipoDanio: json['tipo_danio'],
      imagenUrl: json['imagen_url'],
      estado: json['estado'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parque_id': parqueId,
      'reportero_id': reporteroId,
      'descripcion': descripcion,
      'tipo_danio': tipoDanio,
      'imagen_url': imagenUrl,
      'estado': estado,
    };
  }

  // ============================================================
  // EL MÉTODO QUE TE FALTABA: copyWith
  // ============================================================
  ReporteModel copyWith({
    dynamic id,
    int? parqueId,
    String? reporteroId,
    String? descripcion,
    String? tipoDanio,
    String? imagenUrl,
    String? estado,
    DateTime? createdAt,
  }) {
    return ReporteModel(
      id: id ?? this.id,
      parqueId: parqueId ?? this.parqueId,
      reporteroId: reporteroId ?? this.reporteroId,
      descripcion: descripcion ?? this.descripcion,
      tipoDanio: tipoDanio ?? this.tipoDanio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
