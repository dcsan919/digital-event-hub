import 'package:dio/dio.dart';
import '../models/escenario.dart';

class EscenarioService {
  final Dio _dio = Dio();
  final urlEscenario = 'https://api-digitalevent.onrender.com/api/escenarios';

  Future<List<Escenario>> fetchEscenario() async {
    try {
      final response = await _dio.get(urlEscenario);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Escenario.fromJson(json))
            .toList();
      } else {
        throw Exception('Formato de respuesta no reconocido');
      }
    } catch (e) {
      throw Exception('Error al cargar los asientos: $e');
    }
  }
}
