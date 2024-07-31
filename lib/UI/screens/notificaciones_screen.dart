import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionesScreen extends StatefulWidget {
  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<Map<String, dynamic>> notificaciones = [];
  int? lastNotificacionId;

  @override
  void initState() {
    super.initState();
    _loadLastNotificacionId();
    fetchNotificaciones();
  }

  Future<void> _loadLastNotificacionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastNotificacionId = prefs.getInt('lastNotificacionId');
    });
  }

  Future<void> _saveLastNotificacionId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastNotificacionId', id);
  }

  Future<void> fetchNotificaciones() async {
    final response = await http.get(Uri.parse(
        'https://api-digitalevent.onrender.com/api/notification/getAll'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> fetchedNotifications =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      setState(() {
        notificaciones = _groupNotifications(fetchedNotifications);
        if (notificaciones.isNotEmpty) {
          final last = notificaciones.last;
          if (last['notificacion_id'] != lastNotificacionId) {
            _showNotificationAlert(last);
          }
        }
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
        'details': messages
      };
    }).toList();
  }

  void _showNotificationAlert(Map<String, dynamic> notificacion) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Nueva Notificación'),
            content: Row(
              children: [
                Icon(Icons.notifications, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text('${notificacion['mensaje']}'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  _saveLastNotificacionId(notificacion['notificacion_id']);
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
          title: Text('Detalles de Notificación'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  title: Text(notification['mensaje']),
                  subtitle: Text(
                      'Fecha de envío: ${notification['fecha_envio'].substring(0, 10)}'),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar', style: TextStyle(color: Colors.blue)),
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
      appBar: AppBar(
        title: Text('Notificaciones'),
        backgroundColor: Color.fromARGB(255, 58, 18, 74),
      ),
      body: notificaciones.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final notificacion = notificaciones[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(notificacion['mensaje']),
                    subtitle: Text(
                        'Fecha de envío: ${notificacion['fecha_envio'].substring(0, 10)}'),
                    onTap: () =>
                        _showNotificationDetails(notificacion['details']),
                  ),
                );
              },
            ),
    );
  }
}
