import 'package:deh_client/services/usuario_service.dart';
import '../models/usuario.dart';

class UsuarioRepository {
  final UsuarioService _usuarioService = UsuarioService();

  Future<Usuario> getUserById(int userId) {
    return _usuarioService.fetchUserById(userId);
  }

  Future<void> uploadProfilePicture(imageFile, int userId) {
    return _usuarioService.uploadProfilePicture(imageFile, userId);
  }
}
