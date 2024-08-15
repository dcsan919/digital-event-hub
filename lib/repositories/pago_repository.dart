import 'package:deh_client/services/pago_service.dart';
import '../models/pago.dart';

class PaymentRepository {
  final PaymentService _pagoService = PaymentService();

  Future<String> postPago(PaymentRequest paymentRequest) {
    return _pagoService.createPaymentIntent(paymentRequest);
  }
}
