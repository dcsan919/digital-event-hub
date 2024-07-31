class ListEvents {
  final int? evento_id;
  final String? nombre_evento;
  final DateTime? fecha_inicio;
  final DateTime? fecha_termino;
  final String? hora;
  final String? ubicacion;
  final int? maxPer;
  final String? estado;
  final DateTime? fecha_autorizacion;
  final String? tipo_evento;
  final String? organizador_nombre;
  final String? autorizado_nombre;
  final String? categoria_nombre;
  final String? imagen_url;

  ListEvents({
    this.evento_id,
    this.nombre_evento,
    this.fecha_inicio,
    this.fecha_termino,
    this.hora,
    this.ubicacion,
    this.maxPer,
    this.estado,
    this.fecha_autorizacion,
    this.tipo_evento,
    this.organizador_nombre,
    this.autorizado_nombre,
    this.categoria_nombre,
    this.imagen_url,
  });

  factory ListEvents.fromJson(Map<String, dynamic> json) {
    return ListEvents(
      evento_id: json['evento_id'] as int?,
      nombre_evento: json['nombre_evento'] as String?,
      fecha_inicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'])
          : null,
      fecha_termino: json['fecha_termino'] != null
          ? DateTime.parse(json['fecha_termino'])
          : null,
      hora: json['hora'] as String?,
      ubicacion: json['ubicacion'] as String?,
      maxPer: json['max_per'] as int?,
      estado: json['estado'] as String?,
      fecha_autorizacion: json['fecha_autorizacion'] != null
          ? DateTime.parse(json['fecha_autorizacion'])
          : null,
      tipo_evento: json['tipo_evento'] as String?,
      organizador_nombre: json['organizador_nombre'] as String?,
      autorizado_nombre: json['autorizado_nombre'] as String?,
      categoria_nombre: json['categoria_nombre'] as String?,
      imagen_url: json['imagen_url'] as String?,
    );
  }
}
