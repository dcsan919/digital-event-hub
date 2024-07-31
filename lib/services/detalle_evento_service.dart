import 'package:dio/dio.dart';
import '../models/detalles-evento.dart';

class DetalleEventoService {
  final Dio _dio = Dio();

  Future<DetallesEvento> fetchEventsById(int eventoId) async {
    try {
      final response = await _dio
          .get('https://api-digitalevent.onrender.com/api/detalle/$eventoId');
      if (response.data is Map<String, dynamic>) {
        return DetallesEvento.fromJson(response.data);
      } else if (response.data is List<dynamic>) {
        if (response.data.isNotEmpty) {
          return DetallesEvento.fromJson(response.data[0]);
        } else {
          throw Exception('Lista vacía');
        }
      } else {
        throw Exception('Formato de respuesta no reconocido');
      }
    } catch (e) {
      throw Exception('Error al cargar evento: $e');
    }
  }
}
