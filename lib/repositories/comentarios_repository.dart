import 'package:deh_client/services/comentario_service.dart';
import '../models/comentarios.dart';

class ComentariosRepository {
  final ComentarioService _comentarioService = ComentarioService();

  Future<List<Comentario>> getComentariosByEventoId(int eventoId) {
    return _comentarioService.fetchComentariosByEventoId(eventoId);
  }

  Future<Comentario> postComentary(Comentario dataComentario) {
    return _comentarioService.postComentario(dataComentario);
  }
}
