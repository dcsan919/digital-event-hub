import 'package:deh_client/models/detalles-evento.dart';
import 'package:deh_client/models/pago.dart';
import 'package:deh_client/models/ticket.dart';
import 'package:deh_client/repositories/detalles_evento_repository.dart';
import 'package:deh_client/repositories/pago_repository.dart';
import 'package:deh_client/services/stripe_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../themes/tipo_boleto.dart';
import 'package:provider/provider.dart';
import 'package:deh_client/providers/ticketProvider.dart';
import 'package:dotted_border/dotted_border.dart';

class Carrito extends StatefulWidget {
  final int userId;

  Carrito({required this.userId});

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  final LocalAuthentication auth = LocalAuthentication();
  final PaymentRepository _paymentRepositorie = PaymentRepository();
  late Future<DetallesEvento> futureEvento;
  final DetallesEventoRepository _detallesEventoRepository =
      DetallesEventoRepository();

  Future<void> _authenticateAndShowDialog(
      int eventoId, DetallesEvento evento) async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Por favor autentícate para comprar el boleto',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Autenticación exitosa. Procesando pago...')),
        );

        String? paymentIntentClientSecret =
            await StripeServices.instance.makePaymeny(evento.precio!, 'mxn');

        if (paymentIntentClientSecret != null) {
          _handlePayment(eventoId, evento);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se pudo obtener el client secret')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticación fallida')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error durante el pago: $e')),
      );
    }
  }

  Future<bool> processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _handlePayment(int eventoId, DetallesEvento evento) async {
    bool paymentSuccess = await processPayment();
    if (paymentSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra exitosa')),
      );

      int _calculateAmount(int amount) {
        final calculatedAmount = amount * 100;
        return calculatedAmount;
      }

      PaymentRequest newPaymentRequest = PaymentRequest(
        amount: _calculateAmount(evento.precio!),
        currency: 'mxn',
        descripcion: 'Compra de boleto para el evento: ${evento.nombre_evento}',
        usuarioId: widget.userId,
        eventoId: evento.evento_id!,
      );

      final clientSecret =
          await _paymentRepositorie.postPago(newPaymentRequest);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El pago no se completó')),
      );
    }
  }

  void _showPurchaseDialog(int eventoId) {
    futureEvento = _detallesEventoRepository.getEventById(eventoId);

    final textStyle = GoogleFonts.montserrat(fontSize: 16.0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<DetallesEvento>(
          future: futureEvento,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Row(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Cargando Boleto...'),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('No se pudo cargar el evento.'),
                actions: [
                  TextButton(
                    child: const Text('Cerrar',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('No se encontró el evento.'),
                actions: [
                  TextButton(
                    child: const Text('Cerrar',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else {
              final evento = snapshot.data!;
              return AlertDialog(
                title: const Text('¿Desea comprar este boleto?',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        evento.imagen_url ?? 'no disponible',
                        fit: BoxFit.cover,
                        width: 250.0,
                        height: 200.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text('Evento: ${evento.nombre_evento}', style: textStyle),
                    Text(
                        'Fecha Inicio: ${DateFormat('yyyy-MM-dd').format(evento.fecha_inicio!)}',
                        style: textStyle),
                    Text(
                        'Fecha Fin: ${DateFormat('yyyy-MM-dd').format(evento.fecha_termino!)}',
                        style: textStyle),
                    Text('Costo: \$${evento.precio}', style: textStyle),
                    Text('Organizador: ${evento.organizador_nombre}',
                        style: textStyle),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Aceptar',
                        style: TextStyle(color: Colors.green)),
                    onPressed: () {
                      _authenticateAndShowDialog(evento.evento_id!, evento);
                    },
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final cart = ticketProvider.cart;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          'Carrito',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Text("Boletos agregados",
              style: GoogleFonts.montserrat(fontSize: 17)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final ticket = cart[index];
                return _boletos(ticket);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _boletos(Ticket evento) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          context.read<TicketProvider>().removeTicket(evento);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text('${evento.name} eliminado del carrito'),
              ],
            ),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        height: 127,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 58, 18, 74),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(200, 0, 0, 0),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(65.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(65.0)),
              child: Image.network(
                evento.imagenUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                            'POR: ${evento.organizador}',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            evento.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 1
                                ..color = Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            width: 130,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: getIconColor(evento.tipoEvento),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              "Precio: ${tipoPago(evento.precio)}",
                              style: GoogleFonts.montserrat(
                                  color: getIconColor(evento.tipoEvento)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      width: 40,
                      child: Column(
                        children: [
                          DottedBorder(
                            color: Colors.white70,
                            strokeWidth: 1,
                            borderType: BorderType.Rect,
                            child: SizedBox(
                              height: 50,
                              width: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _showPurchaseDialog(evento.id);
                    },
                  ),
                  Positioned(
                    right: 50,
                    top: 0,
                    bottom: 0,
                    child: DottedBorder(
                      color: Colors.white70,
                      strokeWidth: 2,
                      borderType: BorderType.Rect,
                      child: SizedBox(
                        height: double.infinity,
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
