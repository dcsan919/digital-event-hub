class Comentario {
  int? comentarioId;
  int? usuarioId;
  int? eventoId;
  String? usuarioNombre;
  String? comentario;
  DateTime? fecha;

  Comentario(
      {this.comentarioId,
      this.usuarioId,
      this.eventoId,
      this.usuarioNombre,
      this.comentario,
      this.fecha});

  Map<String, dynamic> toJson() {
    return {
      "evento_id": eventoId,
      "usuario_id": usuarioId,
      "comentario": comentario ?? '',
      "fecha": fecha?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      comentarioId: json['comentario_id'] as int?,
      usuarioId: json['usuario_id'] as int?,
      eventoId: json['evento_id'] as int?,
      usuarioNombre: json['usuario_nombre'] as String?,
      comentario: json['comentario'] as String? ?? '',
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
    );
  }
}
