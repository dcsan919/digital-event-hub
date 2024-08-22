import 'asientos.dart';

class Escenario {
  int? escenarioId;
  int? asiento;
  String? forma;
  int? eventoId;
  List<Asientos>? asientos;

  Escenario(
      {this.escenarioId,
      this.asiento,
      this.forma,
      this.eventoId,
      this.asientos});

  Map<String, dynamic> toJson() {
    return {
      "escenario_id": escenarioId,
      "asiento": asiento,
      "forma": forma,
      "evento_id": eventoId,
      "asientos": asientos
          ?.map((a) => a.toJson())
          .toList() // Asegúrate de tener un toJson en Asientos
    };
  }

  factory Escenario.fromJson(Map<String, dynamic> json) {
    return Escenario(
      escenarioId: json['escenario_id'] as int?,
      asiento: json['asiento'] as int?,
      forma: json['forma'] as String?,
      eventoId: json['evento_id'] as int?,
      asientos: (json['asientos'] as List<dynamic>?)
          ?.map((a) => Asientos.fromJson(a as Map<String, dynamic>))
          .toList(), // Cambiado para mapear la lista de asientos
    );
  }
}
