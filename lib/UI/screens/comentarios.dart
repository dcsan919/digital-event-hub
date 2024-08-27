import 'package:deh_client/UI/widgets/noEvents.dart';
import 'package:deh_client/models/comentarios.dart';
import 'package:deh_client/models/usuario.dart';
import 'package:deh_client/repositories/comentarios_repository.dart';
import 'package:deh_client/repositories/usuario_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../ui/themes/cambiar_modo.dart';

class Comentarios extends StatefulWidget {
  final int eventoId;
  final int userId;
  const Comentarios({super.key, required this.eventoId, required this.userId});

  @override
  State<Comentarios> createState() => _ComentariosState();
}

class _ComentariosState extends State<Comentarios> {
  final ComentariosRepository _comentariosRepository = ComentariosRepository();
  late Future<List<Comentario>> futureComentarios;
  late Future<Map<Comentario, Usuario>> _fetchComentariosYUsuariosFuture;
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  late Future<Usuario> futureUsuario;
  TextEditingController _comentarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComentarios();
    _fetchComentariosYUsuariosFuture = _fetchComentariosYUsuarios();
  }

  void _fetchComentarios() {
    setState(() {
      futureComentarios =
          _comentariosRepository.getComentariosByEventoId(widget.eventoId);
    });
  }

  Future<Map<Comentario, Usuario>> _fetchComentariosYUsuarios() async {
    final comentarios =
        await _comentariosRepository.getComentariosByEventoId(widget.eventoId);

    final Map<Comentario, Usuario> comentariosYUsuarios = {};
    for (final comentario in comentarios) {
      final usuario =
          await _usuarioRepository.getUserById(comentario.usuarioId!);
      comentariosYUsuarios[comentario] = usuario;
    }
    return comentariosYUsuarios;
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _submitData(BuildContext dialogContext) async {
    if (_comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario no puede estar vacío')),
      );
      return;
    }
    try {
      int eventoId = widget.eventoId;
      int userId = widget.userId;
      String comentario = _comentarioController.text;
      DateTime fecha = DateTime.now();

      Comentario newComentario = Comentario(
        eventoId: eventoId,
        usuarioId: userId,
        comentario: comentario,
        fecha: fecha,
      );

      await _comentariosRepository.postComentary(newComentario);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario agregado con éxito')),
      );

      _comentarioController.clear();
      Navigator.pop(dialogContext);
      _fetchComentarios();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar comentario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comentarios',
                      style: GoogleFonts.montserrat(
                          color: modoFondo ? white : black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    OutlinedButton(
                        onPressed: () {
                          _addComentario(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: BorderSide(color: Colors.black, width: 0.5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Agregar',
                              style: GoogleFonts.montserrat(color: white),
                            ),
                            Icon(Icons.add, color: white)
                          ],
                        ))
                  ],
                ),
                Divider(
                  color: modoFondo ? white : black,
                  thickness: 0.5,
                  indent: 0,
                  endIndent: 0,
                )
              ],
            ),
          ),
          FutureBuilder<Map<Comentario, Usuario>>(
            future: _fetchComentariosYUsuariosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: noEvents("No hay comentarios", Icons.comment));
              } else {
                final comentariosYUsuarios = snapshot.data!;
                return _buildComentariosList(comentariosYUsuarios);
              }
            },
          )
        ],
      ),
    );
  }

  void _addComentario(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: modoFondo ? black : white,
            content: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Agrega un comentario a este evento',
                        style: GoogleFonts.montserrat(
                            fontSize: 20, color: modoFondo ? white : black),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _comentarioController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          color: modoFondo ? white : black,
                        ),
                        maxLines: null,
                        minLines: 6,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.green, width: 1),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          hintText: 'Escribe un comentario...',
                          hintStyle: TextStyle(
                            color: modoFondo ? white : black,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.red,
                              side: BorderSide(color: Colors.black, width: 0.5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                            ),
                            child: Text(
                              'Cancelar',
                              style:
                                  GoogleFonts.montserrat(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {
                              _submitData(context);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.green,
                              side: BorderSide(color: Colors.black, width: 0.5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                            ),
                            child: Text(
                              'Agregar',
                              style:
                                  GoogleFonts.montserrat(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          );
        });
      },
    );
  }

  Widget _buildComentariosList(Map<Comentario, Usuario> comentariosYUsuarios) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: comentariosYUsuarios.length,
      itemBuilder: (context, index) {
        final comentario = comentariosYUsuarios.keys.elementAt(index);
        final usuario = comentariosYUsuarios[comentario]!;
        return _buildComentario(comentario, usuario);
      },
    );
  }

  Widget _buildComentario(Comentario comentario, Usuario usuario) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(width: 8),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              child:
                  usuario.fotoPerfil != null && usuario.fotoPerfil!.isNotEmpty
                      ? Image.network(
                          usuario.fotoPerfil!,
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  '${comentario.comentario}',
                  style:
                      GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow
                      .ellipsis, // Agrega elipsis para el desbordamiento de texto
                ),
                subtitle: Text(
                  'Por: ${comentario.usuarioNombre ?? 'Desconocido'}',
                  style: GoogleFonts.montserrat(
                      color: Colors.grey[500], fontSize: 12),
                ),
                trailing: Text(
                  DateFormat('yyyy-MM-dd').format(comentario.fecha!),
                  style:
                      GoogleFonts.montserrat(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
