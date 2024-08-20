import 'package:deh_client/const.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeServices {
  StripeServices._();
  final String paymentIntentUrl = 'https://api.stripe.com/v1/payment_intents';

  static final StripeServices instance = StripeServices._();

  Future<String?> makePaymeny(int amount, String currency) async {
    try {
      String? paymentIntentClientSecret =
          await createPaymentIntent(amount, currency);

      if (paymentIntentClientSecret != null) {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentClientSecret,
                merchantDisplayName: "Digital Event Hub"));
      }

      return paymentIntentClientSecret;
    } catch (e) {
      print(e);
    }
  }

  Future<String?> createPaymentIntent(int amount, String currency) async {
    try {
      final Dio _dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency
      };

      var response = await _dio.post(paymentIntentUrl,
          data: data,
          options:
              Options(contentType: Headers.formUrlEncodedContentType, headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
          }));

      if (response.data != null) {
        return response.data['client_secret'];
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}
