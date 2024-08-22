import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../themes/cambiar_modo.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _events = [];
  final String _geocodingApiKey = 'AIzaSyC9FUsVY75kOP7Z6enysOORvEc5V0OP1KE';
  final String _directionsApiKey = 'AIzaSyC9FUsVY75kOP7Z6enysOORvEc5V0OP1KE';
  LatLng _currentPosition = LatLng(20.5784451, -90.0081358);
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _determinePosition();
  }

  Future<void> _loadEvents() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api-digitalevent.onrender.com/api/eventos/events'));

      if (response.statusCode == 200) {
        final List<dynamic> events = json.decode(response.body);

        if (events.isNotEmpty) {
          setState(() {
            _events.clear();
            _events
                .addAll(events.map((event) => event as Map<String, dynamic>));
            _addMarkers(_events);
          });
        }
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<void> _loadExternalEvents(String city) async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.eventbriteapi.com/v3/events/search/?q=$city&token=YOUR_EXTERNAL_API_KEY'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> externalEvents = data['events'];

        if (externalEvents.isNotEmpty) {
          final externalEventsList = externalEvents.map((event) {
            return {
              'nombre_evento': event['name']['text'],
              'ubicacion': event['venue']['address']
                  ['localized_address_display'],
              'organizador_nombre': event['organization_id'],
              'fecha_inicio': event['start']['local'],
              'fecha_termino': event['end']['local'],
              'imagen_url': event['logo'] != null ? event['logo']['url'] : null,
            };
          }).toList();

          setState(() {
            _events.addAll(externalEventsList);
            _addMarkers(externalEventsList);
          });
        }
      } else {
        throw Exception('Failed to load external events');
      }
    } catch (e) {
      print('Error loading external events: $e');
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Verifica los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Obtén la posición actual
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);

      // Verifica si el marcador ya existe
      if (_markers
          .any((marker) => marker.markerId == MarkerId("currentLocation"))) {
        _markers.removeWhere(
            (marker) => marker.markerId == MarkerId("currentLocation"));
      }

      // Añade el marcador de la ubicación actual
      _markers.add(Marker(
        markerId: MarkerId("currentLocation"),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: "Estás aquí"),
      ));
    });

    // Mueve la cámara del mapa a la ubicación actual
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15),
    );
  }

  void _addMarkers(List<Map<String, dynamic>> events) {
    _markers.addAll(events.map((event) {
      final location = event['ubicacion'];
      final latLng = _getLatLng(location);
      return Marker(
        markerId: MarkerId(event['nombre_evento']),
        position: latLng,
        infoWindow: InfoWindow(
          title: event['nombre_evento'] ?? 'Nombre no disponible',
          snippet: event['organizador_nombre'] ?? 'Organizador no disponible',
        ),
        onTap: () => _showDirections(latLng),
      );
    }).toSet());
  }

  LatLng _getLatLng(String location) {
    return LatLng(20.5784451, -90.0081358);
  }

  Future<void> _showDirections(LatLng destination) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition.latitude},${_currentPosition.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_directionsApiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final points = data['routes'][0]['overview_polyline']['points'];
        final List<PointLatLng> result =
            PolylinePoints().decodePolyline(points);

        if (mounted) {
          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: PolylineId('directions'),
                color: Colors.blue,
                width: 5,
                points: result
                    .map((point) => LatLng(point.latitude, point.longitude))
                    .toList(),
              ),
            );

            _controller?.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(
                    result.map((p) => p.latitude).reduce(min),
                    result.map((p) => p.longitude).reduce(min),
                  ),
                  northeast: LatLng(
                    result.map((p) => p.latitude).reduce(max),
                    result.map((p) => p.longitude).reduce(max),
                  ),
                ),
                50.0,
              ),
            );
          });
        }
      } else {
        throw Exception('Failed to load directions');
      }
    } catch (e) {
      print('Error loading directions: $e');
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$_geocodingApiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];

        if (results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];

          final LatLng position = LatLng(lat, lng);

          if (mounted) {
            setState(() {
              _currentPosition = position;
            });

            // Cargar eventos externos
            await _loadExternalEvents(query);

            // Filtrar eventos cercanos
            final nearbyEvents = _events.where((event) {
              final eventLatLng = _getLatLng(event['ubicacion']);
              final distance = _calculateDistance(position, eventLatLng);
              return distance <=
                  10000; // Define el rango de búsqueda en kilómetros
            }).toList();

            // Mostrar eventos cercanos
            _showEventSelectionDialog(nearbyEvents);

            // Mover cámara a la nueva ubicación
            _controller?.animateCamera(
              CameraUpdate.newLatLng(position),
            );
          }
        } else {
          _showNoResultsDialog();
        }
      } else {
        throw Exception('Failed to search location');
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    final double dLat = _degreesToRadians(end.latitude - start.latitude);
    final double dLng = _degreesToRadians(end.longitude - start.longitude);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void _showEventBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: modoFondo ? black : white,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: event['imagen_url'] != null
                      ? NetworkImage(event['imagen_url'])
                      : null,
                  child: event['imagen_url'] == null ? Icon(Icons.event) : null,
                ),
                title: Text(event['nombre_evento'] ?? 'Nombre no disponible',
                    style: GoogleFonts.montserrat(
                        color: modoFondo ? Colors.white : Colors.black)),
                subtitle: Text(
                    'Inicio: ${event['fecha_inicio'] ?? 'Fecha no disponible'} - Fin: ${event['fecha_termino'] ?? 'Fecha no disponible'}',
                    style: GoogleFonts.montserrat(
                        color: modoFondo ? Colors.white : Colors.black)),
                trailing: Text(event['ubicacion'] ?? 'Ubicación no disponible',
                    style: GoogleFonts.montserrat(
                        color: modoFondo ? Colors.white : Colors.black)),
                onTap: () {
                  final LatLng eventPosition = _getLatLng(
                    event['ubicacion'],
                  );
                  _showDirections(eventPosition);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showEventSelectionDialog(List<Map<String, dynamic>> events) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eventos Cercanos'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event['nombre_evento'] ?? 'Nombre no disponible'),
                  subtitle: Text(event['organizador_nombre'] ??
                      'Organizador no disponible'),
                  onTap: () {
                    final LatLng eventPosition = _getLatLng(event['ubicacion']);
                    _showDirections(eventPosition);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showNoResultsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sin Resultados'),
          content: Text(
              'No se encontraron eventos cercanos en la ubicación buscada.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
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
        backgroundColor: modoFondo ? black : white,
        title: Text(
          'Mapa de Eventos',
          style: GoogleFonts.montserrat(
              color: modoFondo ? white : black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: modoFondo ? white : black,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 10,
            ),
            markers: _markers,
            polylines: _polylines,
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: _isSearching ? 10 : -80,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                  color: modoFondo
                      ? black.withOpacity(0.5)
                      : white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: TextField(
                  style: TextStyle(color: modoFondo ? white : black),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar ubicación',
                    hintStyle: TextStyle(color: modoFondo ? white : black),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: modoFondo ? white : black,
                      ),
                      onPressed: _searchLocation,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(modoFondo ? black : white)),
                onPressed: () => _showEventBottomSheet(context),
                child: Text(
                  'Mostrar Eventos',
                  style:
                      GoogleFonts.montserrat(color: modoFondo ? white : black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
