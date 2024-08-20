import 'package:deh_client/UI/screens/carrito.dart';
import 'package:deh_client/models/detalles-evento.dart';
import 'package:deh_client/models/events.dart';
import 'package:deh_client/models/ticket.dart';
import 'package:deh_client/repositories/detalles_evento_repository.dart';
import 'package:deh_client/repositories/events_repository.dart';
import 'package:deh_client/repositories/pago_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'historial_pagos_screen.dart';
import '../themes/tipo_boleto.dart';

class ComprasScreen extends StatefulWidget {
  final int userId;
  final List<Ticket> cart;

  ComprasScreen({required this.userId, required this.cart});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final PaymentRepository _paymentRepositorie = PaymentRepository();
  final DetallesEventoRepository _detallesEventoRepository =
      DetallesEventoRepository();
  late Future<DetallesEvento> futureEvento;
  final EventsRepository _eventsRepository = EventsRepository();
  late Future<List<ListEvents>> _eventsFuture;
  List<dynamic> ticket = [];
  String? qrData;

  @override
  void initState() {
    super.initState();
    _fetchHistorialPagosAndEvents();
  }

  void _codeqr(dynamic evento, dynamic pago) {
    final userId = widget.userId;
    final eventoId = evento['evento_id'];
    final tipoEvento = evento['tipo_evento'];
    final idPago = pago['pago_id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QR del Boleto',
                style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5),
              Text(
                'Id: ${pago['pago_id']}',
                style: GoogleFonts.montserrat(fontSize: 15),
              ),
            ],
          ),
          content: SizedBox(
            width: 220,
            height: 322,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                QrImageView(
                  data:
                      'idPago=$idPago&userId=$userId&eventoId=$eventoId&tipoEvento=$tipoEvento',
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                ),
                Text(
                  evento['nombre_evento'],
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('Inicia: ${_formatDate(evento['fecha_inicio'])}',
                    style: GoogleFonts.montserrat()),
                Text('Finaliza: ${_formatDate(evento['fecha_termino'])}',
                    style: GoogleFonts.montserrat()),
                Text('Hora: ${evento['hora']}',
                    style: GoogleFonts.montserrat()),
                Text('Tipo de evento: ${evento['tipo_evento']}',
                    style: GoogleFonts.montserrat())
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      print('Error al formatear la fecha: $e');
      return date;
    }
  }

  void _navigateToHistorialPagos() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HistorialPagosScreen(
                userId: widget.userId,
              )),
    );
  }

  Future<void> _fetchHistorialPagosAndEvents() async {
    try {
      final pagosResponse = await http.get(Uri.parse(
          'https://api-digitalevent.onrender.com/api/pagos/historial/${widget.userId}'));
      final eventosResponse = await http.get(Uri.parse(
          'https://api-digitalevent.onrender.com/api/eventos/events'));

      if (pagosResponse.statusCode == 200 &&
          eventosResponse.statusCode == 200) {
        List<dynamic> decodedPagos = jsonDecode(pagosResponse.body);
        List<dynamic> decodedEventos = jsonDecode(eventosResponse.body);

        // Combine the data
        final combinedData = decodedPagos.map((pago) {
          final evento = decodedEventos.firstWhere(
            (event) => event['evento_id'] == pago['evento_id'],
            orElse: () => null,
          );
          return {
            'pago': pago,
            'evento': evento,
          };
        }).toList();

        setState(() {
          ticket = combinedData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          'Tus boletos',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Carrito(
                            userId: widget.userId,
                          )));
            },
          ),
        ],
      ),
      body: ticket.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ticket.length,
              itemBuilder: (context, index) {
                final pago = ticket[index]['pago'];
                final evento = ticket[index]['evento'];
                return _boletos(evento, pago);
              },
            ),
      floatingActionButton: FloatingActionButton(
        splashColor: Colors.green,
        onPressed: _navigateToHistorialPagos,
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Icon(Icons.history),
            Text(
              'Historial',
              style: GoogleFonts.montserrat(fontSize: 11),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _boletos(dynamic evento, dynamic pago) {
    if (evento == null) return Container();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 58, 18, 74),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 58, 18, 74),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 10), // Espacio entre la imagen y el texto
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.all(7.0),
              title: Text(
                evento['nombre_evento'],
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              trailing: Icon(
                size: 36,
                Icons.confirmation_number,
                color: getIconColor(evento['tipo_evento']),
              ),
              onTap: () {
                _codeqr(evento, pago);
                print(_codeqr);
              },
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0)),
            child: Image.network(
              evento['imagen_url'],
              width: 140,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
