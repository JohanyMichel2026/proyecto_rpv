abstract class EntidadBase {
  final dynamic id; // Puede ser int (Comunas) o String/UUID (Reportes)
  final DateTime? createdAt;

  EntidadBase({this.id, this.createdAt});

  // Este contrato obliga a todos los modelos a ser convertibles a JSON para Supabase
  Map<String, dynamic> toMap();
}
