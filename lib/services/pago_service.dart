import 'package:dio/dio.dart';
import 'package:deh_client/models/pago.dart';

class PaymentService {
  final Dio _dio = Dio();
  final String paymentIntentUrl =
      'https://api-digitalevent.onrender.com/api/pagos/pagar';

  Future<String> createPaymentIntent(PaymentRequest paymentRequest) async {
    final response = await _dio.post(
      paymentIntentUrl,
      data: paymentRequest.toJson(),
    );

    if (response.statusCode == 200) {
      final responseData = response.data;
      return responseData['client_secret']; // Asegúrate de que sea un String
    } else {
      throw Exception('Failed to create PaymentIntent');
    }
  }
}
