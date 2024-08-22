class Asientos {
  int? asientoId;
  String? noAsiento;
  String? estado;
  int? usuarioId;

  Asientos({this.asientoId, this.noAsiento, this.estado, this.usuarioId});

  Map<String, dynamic> toJson() {
    return {
      "asiento_id": asientoId,
      "numero_asiento": noAsiento,
      "estado": estado,
      "usuario_id": usuarioId
    };
  }

  factory Asientos.fromJson(Map<String, dynamic> json) {
    return Asientos(
      asientoId: json['asiento_id'] as int?,
      noAsiento: json['numero_asiento'] as String?,
      estado: json['estado'] as String?,
      usuarioId: json['usuario_id'] as int?,
    );
  }
}
