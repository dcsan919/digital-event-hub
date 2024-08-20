class DetallesEvento {
  final int? detalle_evento_id;
  final int? evento_id;
  final String? descripcion;
  final String? requerimientos;
  final int? precio;
  final String? nombre_evento;
  final DateTime? fecha_inicio;
  final DateTime? fecha_termino;
  final String? hora;
  final String? ubicacion;
  final int? maxPer;
  final String? tipo_evento;
  final String? categoria_nombre;
  final String? organizador_nombre;
  final String? imagen_url;

  DetallesEvento({
    this.detalle_evento_id,
    this.evento_id,
    this.descripcion,
    this.requerimientos,
    this.precio,
    this.nombre_evento,
    this.fecha_inicio,
    this.fecha_termino,
    this.hora,
    this.ubicacion,
    this.maxPer,
    this.tipo_evento,
    this.categoria_nombre,
    this.organizador_nombre,
    this.imagen_url,
  });

  factory DetallesEvento.fromJson(Map<String, dynamic> json) {
    return DetallesEvento(
      detalle_evento_id: json['detalle_evento_id'] as int?,
      evento_id: json['evento_id'] as int?,
      descripcion: json['descripcion'] as String?,
      requerimientos: json['requerimientos'] as String?,
      precio: json['Precio'] != null
          ? (double.tryParse(json['Precio']))!.toInt()
          : 0,
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
      tipo_evento: json['tipo_evento'] as String?,
      categoria_nombre: json['categoria'] as String?,
      organizador_nombre: json['organizador_nombre'] as String?,
      imagen_url: json['imagen_url'] as String?,
    );
  }
}
