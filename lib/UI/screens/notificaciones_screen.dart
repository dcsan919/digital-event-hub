import 'package:deh_client/UI/themes/cambiar_modo.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificacionesScreen extends StatefulWidget {
  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<Map<String, dynamic>> notificaciones = [];
  Map<int, bool> notificacionesEstado = {};

  @override
  void initState() {
    super.initState();
    _loadNotificacionesEstado();
    fetchNotificaciones();
  }

  Future<void> _loadNotificacionesEstado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedEstado = prefs.getString('notificacionesEstado');
    if (savedEstado != null) {
      final decoded = jsonDecode(savedEstado) as Map<String, dynamic>;
      setState(() {
        notificacionesEstado = decoded.map((key, value) {
          return MapEntry(
              int.parse(key), value == null ? false : value as bool);
        });
      });
    }
  }

  Future<void> _saveNotificacionesEstado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notificacionesEstado
        .map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString('notificacionesEstado', encoded);
  }

  Future<void> fetchNotificaciones() async {
    final response = await http.get(Uri.parse(
        'https://api-digitalevent.onrender.com/api/notification/getAll'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> fetchedNotifications =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      setState(() {
        notificaciones = _groupNotifications(fetchedNotifications);
        // Actualiza el estado de las notificaciones con la información más reciente
        for (var notificacion in notificaciones) {
          final id = notificacion['notificacion_id'];
          if (notificacionesEstado[id] == null) {
            notificacionesEstado[id] = true; // Marca como nuevo
          }
        }
        _saveNotificacionesEstado(); // Guarda el estado actualizado
      });
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  List<Map<String, dynamic>> _groupNotifications(
      List<Map<String, dynamic>> notifications) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var notification in notifications) {
      final message = notification['mensaje'];
      if (!grouped.containsKey(message)) {
        grouped[message] = [];
      }
      grouped[message]!.add(notification);
    }

    return grouped.entries.map((entry) {
      final messages = entry.value;
      return {
        'mensaje': '${entry.key} (${messages.length})',
        'fecha_envio': messages.last['fecha_envio'],
        'notificacion_id': messages.last['notificacion_id'],
        'details': messages,
        'isNew': notificacionesEstado[messages.last['notificacion_id']] ?? true
      };
    }).toList();
  }

  void _markNotificationAsRead(int notificationId) {
    setState(() {
      notificacionesEstado[notificationId] = false;
    });
    _saveNotificacionesEstado(); // Guarda el estado actualizado
  }

  void _showNotificationAlert(Map<String, dynamic> notificacion) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Nueva Notificación', style: GoogleFonts.montserrat()),
            content: Row(
              children: [
                Icon(Icons.notifications, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text('${notificacion['mensaje']}',
                      style: GoogleFonts.montserrat()),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK',
                    style: GoogleFonts.montserrat(color: Colors.blue)),
                onPressed: () {
                  final id = notificacion['notificacion_id'];
                  _markNotificationAsRead(id); // Marca como leído
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _showNotificationDetails(List<Map<String, dynamic>> notifications) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: modoFondo ? black : white,
          title: Text('Detalles de Notificación',
              style: GoogleFonts.montserrat(color: modoFondo ? white : black)),
          content: Container(
            color: modoFondo ? black : white,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  color: modoFondo ? Colors.grey[900] : white,
                  margin: EdgeInsets.all(10),
                  elevation: 8,
                  shadowColor:
                      Colors.black.withOpacity(0.3), // Color de la sombra
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Borde redondeado
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(notification['mensaje'],
                        style: GoogleFonts.montserrat(
                            color: modoFondo ? white : black)),
                    subtitle: Text(
                        'Fecha de envío: ${notification['fecha_envio'].substring(0, 10)}',
                        style: GoogleFonts.montserrat(
                            color: modoFondo ? Colors.grey[600] : black)),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar',
                  style: GoogleFonts.montserrat(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: modoFondo ? black : white,
      appBar: AppBar(
        title: Text('Notificaciones',
            style: GoogleFonts.montserrat(
                color: modoFondo ? white : black, fontWeight: FontWeight.bold)),
        backgroundColor: modoFondo ? black : white,
      ),
      body: notificaciones.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final notificacion = notificaciones[index];
                final isNew = notificacion['isNew'] as bool? ?? false;

                return Card(
                  color: modoFondo ? Colors.grey[900] : white,
                  margin: EdgeInsets.all(10),
                  elevation: 8, // Ajusta la elevación para efecto
                  shadowColor:
                      Colors.black.withOpacity(0.3), // Color de la sombra
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Borde redondeado
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(notificacion['mensaje'],
                        style: GoogleFonts.montserrat(
                            color: isNew
                                ? Colors.blue
                                : modoFondo
                                    ? Colors.white
                                    : black)),
                    subtitle: Text(
                        'Fecha de envío: ${notificacion['fecha_envio'].substring(0, 10)}',
                        style: GoogleFonts.montserrat(
                            color: isNew
                                ? Colors.blue
                                : modoFondo
                                    ? Colors.grey[500]
                                    : Colors.grey[900])),
                    onTap: () {
                      _showNotificationDetails(notificacion['details']);
                      if (isNew) {
                        _markNotificationAsRead(
                            notificacion['notificacion_id']);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
