class Ticket {
  final int id;
  final String name;
  final String imagenUrl;
  final DateTime fechaInicio;
  final String tipoEvento;
  int quantity;

  Ticket(
      {required this.id,
      required this.name,
      required this.imagenUrl,
      required this.fechaInicio,
      required this.tipoEvento,
      this.quantity = 1});
}
