class PaymentRequest {
  final int amount;
  final String currency;
  final String descripcion;
  final int usuarioId;
  final int eventoId;

  PaymentRequest({
    required this.amount,
    required this.currency,
    required this.descripcion,
    required this.usuarioId,
    required this.eventoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'descripcion': descripcion,
      'usuario_id': usuarioId,
      'evento_id': eventoId,
    };
  }
}
