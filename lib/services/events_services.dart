import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../models/events.dart';

class EventsService {
  final Dio _dio = Dio();
  final String apiUrlF = 'api-digitalevent.onrender.com';
  final String apiUrl = 'https://api-digitalevent.onrender.com/api/eventos/';

  Future<List<ListEvents>> fetchEvents() async {
    try {
      String query = 'events';
      final response = await _dio.get(apiUrl + query);

      if (response.statusCode == 200) {
        List<dynamic> body = response.data;
        return body.map((dynamic item) => ListEvents.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<List<ListEvents>> getFilterNameEvents(String? nombreEvento) async {
    try {
      String query = 'filtro?';
      if (nombreEvento != null && nombreEvento.isNotEmpty) {
        query += 'nombre_evento=${Uri.encodeComponent(nombreEvento)}';
      }

      final response = await http.get(Uri.parse(apiUrl + query));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => ListEvents.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No hay conexión a Internet');
      } else {
        throw Exception('Error al cargar eventos: $e');
      }
    }
  }

  Future<List<ListEvents>> getFilteredEvents(
      String? categoria, String? tipoEvento, String? hora) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (categoria != null && categoria.isNotEmpty) {
        queryParameters['category'] = categoria;
      }
      if (tipoEvento != null && tipoEvento.isNotEmpty) {
        queryParameters['tipo_evento'] = tipoEvento;
      }
      if (hora != null && hora.isNotEmpty) {
        queryParameters['hora'] = hora;
      }

      final uri = Uri.https(apiUrlF, '/api/eventos/filtro', queryParameters);
      print('Query URL: $uri');
      final response = await _dio.getUri(uri);

      if (response.statusCode == 200) {
        List<dynamic> body = response.data;
        return body.map((dynamic item) => ListEvents.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception('No hay conexión a Internet');
        } else if (e.response != null) {
          throw Exception(
              'Error al cargar eventos: ${e.response?.statusMessage}');
        } else {
          throw Exception('Error al cargar eventos: $e');
        }
      } else {
        throw Exception('Error al cargar eventos: $e');
      }
    }
  }

  Future<List<ListEvents>> getFilteredEventsByType(String? tipoEvento) async {
    try {
      String query = 'filtro?';
      if (tipoEvento != null && tipoEvento.isNotEmpty) {
        query += 'tipo_evento=${Uri.encodeComponent(tipoEvento)}&';
      }

      if (query.endsWith('&')) {
        query = query.substring(0, query.length - 1);
      }

      final response = await http.get(Uri.parse(apiUrl + query));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => ListEvents.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No hay conexión a Internet');
      } else {
        throw Exception('Error al cargar eventos: $e');
      }
    }
  }
}
