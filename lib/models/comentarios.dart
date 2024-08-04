class Comentario {
  int? comentarioId;
  int? usuarioId;
  int? eventoId;
  String? comentario;
  DateTime fecha;

  Comentario(
      {this.comentarioId,
      this.usuarioId,
      this.eventoId,
      this.comentario,
      required this.fecha});

  Map<String, dynamic> toJson() {
    return {"comentario": comentario, "fecha": fecha.toIso8601String()};
  }

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
        comentarioId: json['comentario_id'] as int?,
        usuarioId: json['usuario_id'] as int?,
        eventoId: json['evento_id'] as int?,
        comentario: json['comentario'] as String?,
        fecha: DateTime.parse(json['fecha'] as String));
  }
}
