import 'package:deh_client/UI/screens/comentarios.dart';
import 'package:deh_client/UI/widgets/eventos_nav_bar.dart';
import 'package:deh_client/UI/widgets/noInternet.dart';
import 'package:deh_client/repositories/detalles_evento_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/detalles-evento.dart';
import 'package:intl/intl.dart';

class DetallesEventos extends StatefulWidget {
  final int eventoId;
  final int userId;

  const DetallesEventos(
      {Key? key, required this.eventoId, required this.userId})
      : super(key: key);

  @override
  State<DetallesEventos> createState() => _DetallesEventosState();
}

class _DetallesEventosState extends State<DetallesEventos> {
  final DetallesEventoRepository _detallesEventoRepository =
      DetallesEventoRepository();
  late Future<DetallesEvento> futureEvento;
  final ValueNotifier<int> _selectedSectionNotifier = ValueNotifier<int>(0);
  @override
  void initState() {
    super.initState();
    _fetchDetalleEvent();
  }

  void _fetchDetalleEvent() {
    setState(() {
      futureEvento = _detallesEventoRepository.getEventById(widget.eventoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 80,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.white)),
          title: Text(
            'Detalles de Evento',
            style: GoogleFonts.montserrat(color: Colors.white),
          )),
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
                  NabTop(selectedIndexNotifier: _selectedSectionNotifier),
                  SizedBox(height: 20),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<int>(
                    valueListenable: _selectedSectionNotifier,
                    builder: (context, selectedIndex, child) {
                      return _getSectionContent(selectedIndex, futureEvento,
                          widget.eventoId, widget.userId);
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

Widget _getSectionContent(int selectedIndex,
    Future<DetallesEvento> futureEvento, int eventoId, int userId) {
  switch (selectedIndex) {
    case 0:
      return DetallesEventContent(
        detallesEventFuture: futureEvento,
      );
    case 1:
      return Comentarios(
        eventoId: eventoId,
        userId: userId,
      );
    default:
      return DetallesEventContent(
        detallesEventFuture: futureEvento,
      );
  }
}

class DetallesEventContent extends StatelessWidget {
  final Future<DetallesEvento> detallesEventFuture;
  const DetallesEventContent({
    super.key,
    required this.detallesEventFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<DetallesEvento>(
          future: detallesEventFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData) {
              return noInternet();
            } else {
              return _DetalleEvento(snapshot.data!, context);
            }
          },
        ),
      ],
    );
  }
}

Widget _DetalleEvento(DetallesEvento evento, context) {
  final _colorDEH = Color.fromARGB(255, 58, 18, 74);
  return Center(
    child: Container(
      width: 350,
      height: 650,
      child: Stack(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: _colorDEH,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0))),
                    width: 175,
                    height: 650,
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text('Evento: ${evento.nombre_evento}',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Organizador: ${evento.organizador_nombre}',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Fecha inicio: ${evento.fecha_inicio != null ? DateFormat('yyyy-MM-dd').format(evento.fecha_inicio!) : 'Fecha no disponible'}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Fin del evento: ${evento.fecha_termino != null ? DateFormat('yyyy-MM-dd').format(evento.fecha_termino!) : 'Fecha no disponible'}',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Hora: ${evento.hora}       ',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Categoría: ${evento.categoria_nombre}',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          SizedBox(
                            height: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ubicación:',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text('${evento.ubicacion}',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 14)),
                            ],
                          ),
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
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //AGREGAR BOLETO
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 9, 143, 13)
                                  .withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 9, 143, 13),
                            side: BorderSide(
                                color: Color.fromARGB(255, 9, 143, 13),
                                width: 0.6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                topRight: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Agregar Boleto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.trolley,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      //ACTIVAR NOTIFICACIONES
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.white, width: 0.6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                bottomLeft: Radius.circular(0),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  //VOLVER AL INICIO
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color:
                              Color.fromARGB(255, 255, 0, 0).withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 0, 0),
                        side: BorderSide(
                            color: Color.fromARGB(255, 255, 0, 0), width: 0.6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 75, vertical: 5),
                      ),
                      child: Text(
                        'Volver al inicio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
