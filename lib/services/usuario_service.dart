import 'package:dio/dio.dart';
import '../models/usuario.dart';

class UsuarioService {
  final Dio _dio = Dio();

  Future<Usuario> fetchUserById(int userId) async {
    try {
      final response = await _dio
          .get('https://api-digitalevent.onrender.com/api/users/$userId');
      if (response.data is Map<String, dynamic>) {
        return Usuario.fromJson(response.data);
      } else if (response.data is List<dynamic>) {
        if (response.data.isNotEmpty) {
          return Usuario.fromJson(response.data[0]);
        } else {
          throw Exception('No existe el usuario');
        }
      } else {
        throw Exception('Formato de respuesta no reconocido');
      }
    } catch (e) {
      throw Exception('Error al cargar el usuario: $e');
    }
  }

  Future<Response?> uploadProfilePicture(String imageFile, int userId) async {
    try {
      String url =
          'https://api-digitalevent.onrender.com/api/imagenes/upload/$userId';
      if (imageFile.isEmpty) {
        throw Exception('La ruta de la imagen es inválida o vacía');
      }
      FormData formData = new FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile, filename: "dp.jpg")
      });

      Response response = await Dio().put(
        url,
        data: formData,
      );

      return response;
    } on DioException catch (e) {
      print("Error al subir la imagen: $e");
      return e.response;
    }
  }
}
