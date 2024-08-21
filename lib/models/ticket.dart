class Ticket {
  final int id;
  final String name;
  final String imagenUrl;
  final DateTime fechaInicio;
  final String tipoEvento;
  final String organizador;
  final int precio;
  final String asiento;
  final int quantity;

  Ticket(
      {required this.id,
      required this.name,
      required this.imagenUrl,
      required this.fechaInicio,
      required this.tipoEvento,
      required this.organizador,
      required this.precio,
      required this.asiento,
      required this.quantity});
}
