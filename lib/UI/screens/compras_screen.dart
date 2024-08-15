import 'package:deh_client/models/pago.dart';
import 'package:deh_client/repositories/pago_repository.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'historial_pagos_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class ComprasScreen extends StatefulWidget {
  final int userId;
  final int eventoId;

  ComprasScreen({required this.userId, required this.eventoId});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  List eventos = [];
  final LocalAuthentication auth = LocalAuthentication();
  final PaymentRepository _paymentRepositorie = PaymentRepository();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey =
        'pk_test_51Pnrfa2MBIXEGajF1py0dIHwiDBQ55TStKFmjEkxqiUk4AFs7kHhMgO4lUX7fIBlxGVmoYKgJKTnHJZgOPCmn9G100MZiI64C1';
    super.initState();
    fetchEventos();
  }

  Future<void> fetchEventos() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api-digitalevent.onrender.com/api/eventos/events'));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            eventos = jsonDecode(response.body);
          });
        }
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showPaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.system,
          merchantDisplayName: 'Digital Event Hub',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago realizado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error durante el pago: $e')),
      );
    }
  }

  Future<void> _authenticateAndShowDialog(Map evento) async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Por favor autentícate para comprar el boleto',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Autenticación exitosa. Procesando pago...')),
        );

        PaymentRequest newPaymentRequest = PaymentRequest(
          amount: 1000, // Monto en centavos
          currency: 'usd', // Asegúrate de que la moneda sea válida
          descripcion: 'Compra de boleto para ${evento['nombre_evento']}',
          usuarioId: 70, // Usa el ID de usuario del widget
          eventoId: 1, // Usa el ID del evento del widget
        );

        final clientSecret =
            await _paymentRepositorie.postPago(newPaymentRequest);

        if (clientSecret != null && clientSecret.isNotEmpty) {
          await _showPaymentSheet(clientSecret);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo obtener el client secret')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Autenticación fallida')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error durante el pago: $e')),
      );
    }
  }

  void _showPurchaseDialog(Map evento) {
    final textStyle = TextStyle(
      fontFamily: 'Montserrat', // Aplica la fuente Montserrat
      fontSize: 16.0, // Tamaño de fuente
      fontWeight: FontWeight.normal, // Peso de fuente
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Desea comprar este boleto?',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 18.0, // Tamaño de fuente del título
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    12.0), // Ajusta el radio del borde redondeado
                child: Image.network(
                  evento['imagen_url'],
                  fit: BoxFit.cover, // Ajusta cómo se escala la imagen
                  width: 250.0, // Ancho de la imagen
                  height: 200.0, // Alto de la imagen
                ),
              ),
              SizedBox(height: 10.0), // Espacio entre la imagen y el texto
              Text('Evento: ${evento['nombre_evento']}', style: textStyle),
              Text('Fecha Inicio: ${evento['fecha_inicio'].substring(0, 10)}',
                  style: textStyle),
              Text('Fecha Fin: ${evento['fecha_termino'].substring(0, 10)}',
                  style: textStyle),
              Text('Costo: \$${evento['max_per']}', style: textStyle),
              Text('Organizador: ${evento['organizador_nombre']}',
                  style: textStyle),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar', style: TextStyle(color: Colors.green)),
              onPressed: () {
                _authenticateAndShowDialog(evento);
              },
            ),
          ],
        );
      },
    );
  }

  Color _getIconColor(String tipoEvento) {
    if (tipoEvento == 'Privado') {
      return Color.fromARGB(255, 255, 215, 0); // Dorado
    } else if (tipoEvento == 'Público') {
      return Colors.green; // Verde
    } else {
      return Colors.grey; // Color por defecto
    }
  }

  void _navigateToHistorialPagos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistorialPagosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Boletos',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Color.fromARGB(255, 236, 231, 237),
      ),
      body: Container(
        color: Color.fromARGB(255, 241, 240, 242),
        child: eventos.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  final evento = eventos[index];
                  double costo = evento['max_per'].toDouble();
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 58, 18, 74),
                      borderRadius: BorderRadius.circular(15),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            evento['imagen_url'],
                            width: 120, // Tamaño de la imagen
                            height: 120, // Tamaño de la imagen
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                            width: 10), // Espacio entre la imagen y el texto
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Organizador: ${evento['organizador_nombre']}',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white70),
                                ),
                                Text(
                                  'Inicia: ${evento['fecha_inicio']}',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white70),
                                ),
                                Text(
                                  'Evento: ${evento['tipo_evento']}',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white70),
                                ),
                                Text(
                                  'Costo: \$${evento['max_per']}',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white70),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.confirmation_number,
                              color: _getIconColor(evento['tipo_evento']),
                              size: 30,
                            ),
                            onTap: () => _showPurchaseDialog(evento),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToHistorialPagos,
        child: Icon(Icons.history),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
