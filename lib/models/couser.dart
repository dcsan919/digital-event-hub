import 'package:deh_client/models/escenario.dart';

import './comentarios.dart';
import './usuario.dart';

class ComentarioConUsuario {
  final Comentario comentario;
  final Usuario usuario;
  final Escenario escenario;

  ComentarioConUsuario(
      {required this.comentario,
      required this.usuario,
      required this.escenario});
}
