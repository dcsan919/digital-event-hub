import 'package:deh_client/repositories/detalles_evento_repository.dart';
import 'package:flutter/material.dart';
import '../../models/detalles-evento.dart';

class DetallesEventos extends StatefulWidget {
  final int eventoId;

  const DetallesEventos({Key? key, required this.eventoId}) : super(key: key);

  @override
  State<DetallesEventos> createState() => _DetallesEventosState();
}

class _DetallesEventosState extends State<DetallesEventos> {
  final DetallesEventoRepository _detallesEventoRepository =
      DetallesEventoRepository();
  late Future<DetallesEvento> futureEvento;

  @override
  void initState() {
    super.initState();
    futureEvento = _detallesEventoRepository.getEventById(widget.eventoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 90,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        title:
            Text('Detalles de Evento', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<DetallesEvento>(
        future: futureEvento,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Evento no encontrado'));
          } else {
            final evento = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _DetalleEvento(evento),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

Widget _DetalleEvento(DetallesEvento evento) {
  final _colorDEH = Color.fromARGB(255, 58, 18, 74);
  final _colorWhite = Colors.white;
  return Center(
    child: Container(
      width: 350,
      height: 650,
      child: Row(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: _colorDEH,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
                width: 175,
                height: 650,
                child: Container(
                  margin: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Text('Evento: ${evento.nombre_evento}',
                          style: TextStyle(color: _colorWhite, fontSize: 20)),
                      Text('Organizador: ${evento.organizador_nombre}',
                          style: TextStyle(color: _colorWhite, fontSize: 15)),
                      Text('Fecha inicio: ${evento.fecha_inicio}',
                          style: TextStyle(color: _colorWhite, fontSize: 15)),
                      Text('Fin del evento: ${evento.fecha_termino}',
                          style: TextStyle(color: _colorWhite, fontSize: 15)),
                      Text('Hora: ${evento.hora}',
                          style: TextStyle(color: _colorWhite, fontSize: 15)),
                      Text('Categoria: ${evento.categoria_nombre}',
                          style: TextStyle(color: _colorWhite, fontSize: 15)),
                      Text('Ubicación: ${evento.ubicacion}',
                          style: TextStyle(color: _colorWhite, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                width: 175,
                height: 650,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0)),
                  child: Image.network(
                      evento.imagen_url ??
                          'https://imgs.search.brave.com/yhxBu52UuvVKXg7IqZS9no1cqFXsyR_d-rsBrqZPZvo/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/bWV4aWNvZGVzY29u/b2NpZG8uY29tLm14/L3dwLWNvbnRlbnQv/dXBsb2Fkcy8yMDIx/LzEwL1ZBUVVFUklB/LURFLUFOSU1BUy0y/MDIxXzUyLTkwMHg1/OTYuanBn',
                      height: 20.0,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          Divider()
        ],
      ),
    ),
  );
}
