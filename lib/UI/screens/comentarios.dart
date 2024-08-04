import 'package:deh_client/UI/widgets/noEvents.dart';
import 'package:deh_client/UI/widgets/noInternet.dart';
import 'package:deh_client/models/comentarios.dart';
import 'package:deh_client/repositories/comentarios_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Comentarios extends StatefulWidget {
  final int eventoId;
  final int userId;
  const Comentarios({super.key, required this.eventoId, required this.userId});

  @override
  State<Comentarios> createState() => _ComentariosState();
}

class _ComentariosState extends State<Comentarios> {
  final ComentariosRepository _comentariosRepository = ComentariosRepository();
  late Future<List<Comentario>> _futureComentarios;
  TextEditingController _comentarioController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchComentarios();
  }

  void _fetchComentarios() {
    setState(() {
      _futureComentarios =
          _comentariosRepository.getComentariosByEventoId(widget.eventoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comentarios',
                      style: GoogleFonts.montserrat(
                          color: Colors.black,
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
                              'Agregar Comenatario',
                              style:
                                  GoogleFonts.montserrat(color: Colors.white),
                            ),
                            Icon(Icons.add, color: Colors.white)
                          ],
                        ))
                  ],
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 0.5,
                  indent: 0,
                  endIndent: 0,
                )
              ],
            ),
          ),
          FutureBuilder<List<Comentario>>(
            future: _futureComentarios,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                final error = snapshot.error.toString();
                if (error.contains('No hay conexión a Internet')) {
                  return noInternet();
                }
                return Text('Error: $error');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return noEvents();
              } else {
                return _buildComentariosList(snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }

  void disponse() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (_comentarioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El comentario no puede estar vacío')),
      );
      return;
    }
    try {
      int eventoId = widget.eventoId;
      int userId = widget.userId;
      String comentario = _comentarioController.text;
      DateTime fecha = DateTime.now();

      Comentario newComentario = Comentario(
        comentario: comentario,
        fecha: fecha,
      );

      await _comentariosRepository.postComentary(
          eventoId, userId, newComentario);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comentario agregado con éxito')),
      );

      _comentarioController.clear();
      Navigator.pop(context);
      _fetchComentarios();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar comentario: $e')),
      );
    }
  }

  void _addComentario(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 1,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Text(
                    'Agrega un comentario a este evento',
                    style: GoogleFonts.montserrat(fontSize: 20),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _comentarioController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 6,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.green, width: 1),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        hintText: 'Escribe un comentario...'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _submitData();
                          print(_submitData);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: BorderSide(color: Colors.black, width: 0.5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                        ),
                        child: Text(
                          'Agregar',
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
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
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildComentariosList(List<Comentario> comentarios) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: comentarios.length,
      itemBuilder: (context, index) {
        return _buildComentario(comentarios[index]);
      },
    );
  }

  Widget _buildComentario(Comentario comentario) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(
            '${comentario.comentario}',
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
          ),
          subtitle: Text(
            'Por: ${comentario.usuarioId ?? 'Desconocido'}',
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12),
          ),
          trailing: Text(DateFormat('yyyy-MM-dd').format(comentario.fecha),
              style:
                  GoogleFonts.montserrat(color: Colors.white54, fontSize: 12)),
        ),
      ),
    );
  }
}
