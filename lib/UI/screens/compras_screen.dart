import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'historial_pagos_screen.dart';

class ComprasScreen extends StatefulWidget {
  @override
  _ComprasScreenState createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  List eventos = [];
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
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

  Future<void> _authenticateAndShowDialog(Map evento) async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Por favor autentícate para comprar el boleto',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        _showPurchaseDialog(evento);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Autenticación fallida')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _showPurchaseDialog(Map evento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Desea comprar este boleto?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Evento: ${evento['nombre_evento']}'),
              Text('Fecha Inicio: ${evento['fecha_inicio'].substring(0, 10)}'),
              Text('Fecha Fin: ${evento['fecha_termino'].substring(0, 10)}'),
              Text('Costo: \$${evento['max_per']}'),
              Text('Organizador: ${evento['organizador_nombre']}'),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _getIconColor(double costo) {
    if (costo == 0 || costo == 0.0) {
      return Colors.green;
    } else if (costo > 0 && costo <= 300) {
      return Colors.pink;
    } else {
      return Colors.grey;
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
        title: Text('Lista de Boletos'),
        backgroundColor: Color.fromARGB(255, 58, 18, 74),
      ),
      body: eventos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                final evento = eventos[index];
                double costo = evento['max_per'].toDouble();
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(evento['nombre_evento']),
                    subtitle: Text(
                        'Fecha: ${evento['fecha_inicio'].substring(0, 10)}\nCosto: \$${evento['max_per']}'),
                    trailing: Icon(
                      Icons.confirmation_number,
                      color: _getIconColor(costo),
                    ),
                    onTap: () => _authenticateAndShowDialog(evento),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToHistorialPagos,
        child: Icon(Icons.history),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
