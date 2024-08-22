import 'package:deh_client/UI/screens/detalles_event.dart';
import 'package:deh_client/UI/widgets/filter_events.dart';
import 'package:deh_client/UI/widgets/noEvents.dart';
import 'package:deh_client/UI/widgets/noInternet.dart';
import 'package:deh_client/UI/widgets/sidebar.dart';
import 'package:deh_client/models/events.dart';
import 'package:deh_client/repositories/events_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../models/usuario.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import '../themes/tipo_boleto.dart';
import '../themes/cambiar_modo.dart';

// ignore: must_be_immutable
class ListEvent extends StatefulWidget {
  int userId;
  final Usuario usuario;

  ListEvent({required this.userId, required this.usuario});

  @override
  _ListEventState createState() => _ListEventState();
}

class _ListEventState extends State<ListEvent> {
  final List<bool> _selections = <bool>[false, true, false];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final EventsRepository _eventsRepository = EventsRepository();
  late Future<List<ListEvents>> _eventsFuture;
  final TextEditingController _nombreController = TextEditingController();
  final List<Widget> eventos = <Widget>[
    const Center(
        child: Text(
      'Público',
      style: TextStyle(fontSize: 16),
    )),
    const Center(
        child: Icon(
      Icons.home,
      size: 20,
    )),
    const Center(child: Text('Privado', style: TextStyle(fontSize: 16))),
  ];
  String? initialCategoria;
  String? initialTipoEvento;
  String? initialHora;
  String? _selectedCategoria;
  String? _selectedTipoEvento;
  String? _selectedHora;

  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() {
    setState(() {
      _eventsFuture = _eventsRepository.getEvents();
    });
  }

  void _fetchEventsByType(String tipoEvento) {
    setState(() {
      _eventsFuture = _eventsRepository.filterEventsByType(tipoEvento);
    });
  }

  void _fetchFilteredEvents(
      String? categoria, String? tipoEvento, String? hora) {
    setState(() {
      _selectedCategoria = categoria;
      _selectedTipoEvento = tipoEvento;
      _selectedHora = hora;
      _eventsFuture = _eventsRepository.filterEvents(
          categoria ?? '', tipoEvento ?? '', hora ?? '');
    });
  }

  void _fetchFilteredEventsName(String? nombre) {
    setState(() {
      _eventsFuture = _eventsRepository.filterEventsName(nombre ?? '');
    });
  }

  void _applyFilters(String? tipoEvento) {
    setState(() {
      _selectedTipoEvento = tipoEvento;
      for (int i = 0; i < _selections.length; i++) {
        _selections[i] = false;
      }
      if (_selectedTipoEvento == 'Publico') {
        _selections[0] = true;
        _selections[1] = false;
        _selections[2] = false;
      } else if (_selectedTipoEvento == 'Privado') {
        _selections[0] = false;
        _selections[1] = false;
        _selections[2] = true;
      } else {
        _selections[0] = false;
        _selections[1] = true;
        _selections[2] = false;
      }
      _fetchEventsByType(_selectedTipoEvento ?? '');
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedHora = null;
      _selectedCategoria = null;
      _selectedTipoEvento = null;
      if (_selectedTipoEvento == null &&
          _selectedCategoria == null &&
          _selectedHora == null) {
        _selections[0] = false;
        _selections[1] = true;
        _selections[2] = false;
        _fetchEvents();
      }
    });
  }

  void _showClearFiltersDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Borrar Filtros"),
          content: Text("¿Está seguro de que desea borrar los filtros?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Sí"),
              onPressed: () {
                _clearFilters();
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
    bool hasActiveFilters =
        _selectedCategoria != null && _selectedCategoria!.isNotEmpty ||
            _selectedTipoEvento != null && _selectedTipoEvento!.isNotEmpty ||
            _selectedHora != null && _selectedHora!.isNotEmpty;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: modoFondo ? black : white,
        appBar: AppBar(
          backgroundColor: modoFondo ? black : white,
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          surfaceTintColor: modoFondo ? black : white,
          title: Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _nombreController,
              style: TextStyle(
                color: modoFondo ? white : black,
              ),
              decoration: InputDecoration(
                  labelText: 'Buscar eventos',
                  labelStyle: TextStyle(
                    color: modoFondo ? white : black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Container(
                      width: 75,
                      child: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        icon:
                            Icon(Icons.menu, color: modoFondo ? white : black),
                      )),
                  suffixIcon: IconButton(
                      onPressed: () {
                        _fetchFilteredEventsName(_nombreController.text);
                      },
                      icon: Icon(Icons.search,
                          color: modoFondo ? Colors.white : Colors.black))),
            ),
          ),
        ),
        drawer: Sidebar(
          userId: widget.userId,
          usuario: widget.usuario,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  Expanded(
                    child: Text("Lista de eventos",
                        style: GoogleFonts.montserrat(
                            color: modoFondo ? white : black,
                            textStyle: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold))),
                  ),
                  if (hasActiveFilters)
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showClearFiltersDialog(context);
                      },
                    ),
                  OutlinedButton(
                    onPressed: () {
                      showFilterDialog(
                          context, _fetchFilteredEvents, _applyFilters,
                          initialCategoria: _selectedCategoria,
                          initialTipoEvento: _selectedTipoEvento,
                          initialHora: _selectedHora);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: hasActiveFilters
                          ? Color(0xFF3A124A)
                          : Colors.transparent,
                      side: BorderSide(
                          color: hasActiveFilters
                              ? Colors.transparent
                              : modoFondo
                                  ? white
                                  : black,
                          width: 0.6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                    ),
                    child: Text(
                      'Filtros',
                      style: TextStyle(
                        color: hasActiveFilters
                            ? white
                            : modoFondo
                                ? white
                                : black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ]),
              ),
              Center(
                child: ToggleButtons(
                    constraints:
                        const BoxConstraints(minWidth: 100, minHeight: 40.0),
                    borderRadius: BorderRadius.circular(20),
                    fillColor: const Color(0xFF3A124A),
                    selectedColor: Colors.white,
                    color: modoFondo ? white : black,
                    borderWidth: 1,
                    selectedBorderColor: modoFondo ? white : black,
                    borderColor: modoFondo ? white : black,
                    children: eventos,
                    isSelected: _selections,
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < _selections.length; i++) {
                          _selections[i] = i == index;
                        }

                        if (index == 0) {
                          _selectedTipoEvento = 'Publico';
                        } else if (index == 1) {
                          _selectedTipoEvento = null;
                        } else if (index == 2) {
                          _selectedTipoEvento = 'Privado';
                        }

                        if (_selectedTipoEvento == null &&
                            _selectedCategoria == null &&
                            _selectedHora == null) {
                          _fetchEvents();
                        } else {
                          _fetchFilteredEvents(_selectedCategoria,
                              _selectedTipoEvento, _selectedHora);
                        }
                      });
                    }),
              ),
              const SizedBox(
                height: 15,
              ),
              const Divider(
                color: Colors.black,
                height: 25,
                indent: 30,
                endIndent: 30,
                thickness: 0.8,
              ),
              FutureBuilder<List<ListEvents>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError
                      .toString()
                      .contains('No hay conexión a Internet')) {
                    return noInternet();
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return noEvents(
                        "No se encontraron Eventos", Icons.search_off);
                  } else {
                    return _buildEventsList(snapshot.data!);
                  }
                },
              ),
            ],
          ),
        ));
  }

  Widget _buildEventsList(List<ListEvents> events) {
    const _colorText = Colors.white;
    const _colorDEH = Color.fromARGB(255, 58, 18, 74);
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                  child: Image.network(
                      event.imagen_url ??
                          'https://imgs.search.brave.com/yhxBu52UuvVKXg7IqZS9no1cqFXsyR_d-rsBrqZPZvo/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/bWV4aWNvZGVzY29u/b2NpZG8uY29tLm14/L3dwLWNvbnRlbnQv/dXBsb2Fkcy8yMDIx/LzEwL1ZBUVVFUklB/LURFLUFOSU1BUy0y/MDIxXzUyLTkwMHg1/OTYuanBn',
                      height: 120.0,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
                Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: _colorDEH,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Color.fromRGBO(58, 18, 74, 255).withOpacity(0.5),
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
                    child: ListTile(
                      title: Text(
                        event.nombre_evento ?? 'Texto no disponible',
                        style: GoogleFonts.montserrat(
                            color: _colorText, fontSize: 19),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Organizador: ${event.organizador_nombre}',
                              style: GoogleFonts.montserrat(
                                  color: _colorText, fontSize: 13)),
                          Text(
                              'Inicia: ${event.fecha_inicio != null ? DateFormat('yyyy-MM-dd').format(event.fecha_inicio!) : 'Fecha no disponible'}',
                              style: GoogleFonts.montserrat(
                                  color: _colorText, fontSize: 13))
                        ],
                      ),
                      trailing: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                )
                              ],
                              color: getIconColor(event.tipo_evento!),
                              borderRadius: BorderRadius.circular(20.0)),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallesEventos(
                                    eventoId: event.evento_id!,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              Bootstrap.ticket_detailed_fill,
                              color: _colorText,
                            ),
                          )),
                    )),
              ],
            ),
          );
        });
  }
}
