import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistorialPagosScreen extends StatefulWidget {
  final int userId;

  HistorialPagosScreen({required this.userId});
  @override
  State<HistorialPagosScreen> createState() => _HistorialPagosScreenState();
}

class _HistorialPagosScreenState extends State<HistorialPagosScreen> {
  List pagos = [];
  bool _isExtended = false;

  @override
  void initState() {
    super.initState();
    fetchHistorialPagos(widget.userId);
  }

  Future<void> fetchHistorialPagos(int userId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api-digitalevent.onrender.com/api/pagos/historial/$userId'));

      if (response.statusCode == 200) {
        List decodedPagos = jsonDecode(response.body);
        decodedPagos.sort((a, b) {
          DateTime dateA = DateTime.parse(a['fecha']);
          DateTime dateB = DateTime.parse(b['fecha']);
          return dateB
              .compareTo(dateA); // Ordenar del más reciente al más antiguo
        });
        setState(() {
          pagos = decodedPagos;
        });
      } else {
        throw Exception('Failed to load payment history');
      }
    } catch (e) {
      print(e);
    }
  }

  void _showPaymentDetails(Map pago) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.monetization_on,
                color: Colors.green,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Detalles del Pago',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Monto: \$${pago['monto']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Fecha: ${pago['fecha'].substring(0, 10)}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Fecha Expiración: ${pago['fecha_expiracion'].substring(0, 10)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Marcar el pago como revisado
    setState(() {
      pago['isReviewed'] = true; // Esto solo cambia el estado local
    });

    // Enviar solicitud para actualizar el estado en el servidor (opcional)
    // await http.post(
    //   Uri.parse('https://api-digitalevent.onrender.com/api/pagos/update_review_status'),
    //   body: jsonEncode({'pago_id': pago['pago_id'], 'isReviewed': true}),
    // );
  }

  void _sharePaymentHistory() {
    String paymentDetails = pagos.map((pago) {
      return 'Monto: \$${pago['monto']}\nFecha: ${pago['fecha'].substring(0, 10)}\nFecha Expiración: ${pago['fecha_expiracion'].substring(0, 10)}\nUsuario ID: ${pago['usuario_id']}\n';
    }).join('\n');

    Share.share(paymentDetails, subject: 'Historial de Pagos');
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.ListView.builder(
            itemCount: pagos.length,
            itemBuilder: (context, index) {
              final pago = pagos[index];
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Historial de compra',
                      style: pw.TextStyle(fontSize: 20)),
                  pw.Text('Monto: \$${pago['monto']}',
                      style: pw.TextStyle(fontSize: 16)),
                  pw.Text('Fecha: ${pago['fecha'].substring(0, 10)}',
                      style: pw.TextStyle(fontSize: 16)),
                  pw.Text(
                      'Fecha Expiración: ${pago['fecha_expiracion'].substring(0, 10)}',
                      style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  String _calculateAmount(String monto) {
    final double amount = double.parse(monto); // Convertir de String a double
    final calculatedAmount = amount / 100; // Realizar la operación aritmética
    return calculatedAmount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Historial de Pagos',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: pagos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pagos.length,
              itemBuilder: (context, index) {
                final pago = pagos[index];
                bool isReviewed = pago['isReviewed'] ?? false;

                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(10),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Icon(
                      isReviewed ? Icons.check_circle : Icons.info,
                      color: isReviewed ? Colors.green : Colors.orange,
                    ),
                    title: Text('Monto: \$${_calculateAmount(pago['monto'])}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${pago['fecha'].substring(0, 10)}'),
                        Text(
                            'Fecha Expiración: ${pago['fecha_expiracion'].substring(0, 10)}'),
                        if (!isReviewed)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No revisado',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () => _showPaymentDetails(pago),
                  ),
                );
              },
            ),
      floatingActionButton: _isExtended
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: _sharePaymentHistory,
                  child: Icon(Icons.share),
                  tooltip: 'Compartir Historial',
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _exportToPDF,
                  child: Icon(Icons.picture_as_pdf),
                  tooltip: 'Exportar como PDF',
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isExtended = false;
                    });
                  },
                  child: Icon(Icons.close),
                  tooltip: 'Cerrar Opciones',
                ),
              ],
            )
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isExtended = true;
                });
              },
              child: Icon(Icons.add),
              tooltip: 'Más Opciones',
            ),
    );
  }
}
