import 'package:dio/dio.dart';
import '../models/comentarios.dart';

class ComentarioService {
  final Dio _dio = Dio();
  final urlComentarios = 'https://api-digitalevent.onrender.com/api/comentario';

  Future<List<Comentario>> fetchComentariosByEventoId(int eventoId) async {
    try {
      final response = await _dio.get('$urlComentarios/list/$eventoId');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Comentario.fromJson(json))
            .toList();
      } else {
        throw Exception('Formato de respuesta no reconocido');
      }
    } catch (e) {
      throw Exception('Error al cargar comentarios: $e');
    }
  }

  Future<Comentario> postComentario(Comentario dataComentario) async {
    try {
      String url = '$urlComentarios/create';

      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ));
      print("URL de POST: $url");
      print("Datos enviados: ${dataComentario.toJson()}");

      final response = await _dio.post(url, data: dataComentario.toJson());

      if (response.data is Map) {
        return Comentario.fromJson(response.data);
      } else {
        throw Exception('Formato de respuesta no reconocido');
      }
    } catch (e) {
      throw Exception('Error al agregar el comentario: $e');
    }
  }
}
