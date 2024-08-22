import 'package:dio/dio.dart';
import '../models/asientos.dart';

class AsientoServices {
  final Dio _dio = Dio();
  final urlAsiento = 'https://api-digitalevent.onrender.com/api/asientos';

  Future<List<Asientos>> fetchAsiento() async {
    try {
      final response = await _dio.get(urlAsiento);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Asientos.fromJson(json))
            .toList();
      } else {
        throw Exception('Formato de respuesta no reconocido');
      }
    } catch (e) {
      throw Exception('Error al cargar los asientos: $e');
    }
  }
}
