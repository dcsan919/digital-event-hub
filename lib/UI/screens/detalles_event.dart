import 'package:deh_client/UI/screens/asientos.dart';
import 'package:deh_client/UI/screens/carrito.dart';
import 'package:deh_client/UI/screens/comentarios.dart';
import 'package:deh_client/UI/themes/tipo_boleto.dart';
import 'package:deh_client/UI/widgets/eventos_nav_bar.dart';
import 'package:deh_client/UI/widgets/noInternet.dart';
import 'package:deh_client/models/ticket.dart';
import 'package:deh_client/providers/ticketProvider.dart';
import 'package:deh_client/repositories/detalles_evento_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/detalles-evento.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../ui/themes/cambiar_modo.dart';

class DetallesEventos extends StatefulWidget {
  final int eventoId;
  final int userId;

  const DetallesEventos(
      {Key? key, required this.eventoId, required this.userId})
      : super(key: key);

  @override
  State<DetallesEventos> createState() => _DetallesEventosState();
}

class _DetallesEventosState extends State<DetallesEventos> {
  final DetallesEventoRepository _detallesEventoRepository =
      DetallesEventoRepository();
  late Future<DetallesEvento> futureEvento;
  final ValueNotifier<int> _selectedSectionNotifier = ValueNotifier<int>(0);
  List<Ticket> cart = [];
  int _quantity = 2;

  @override
  void initState() {
    super.initState();
    _fetchDetalleEvent();
  }

  void _fetchDetalleEvent() {
    setState(() {
      futureEvento = _detallesEventoRepository.getEventById(widget.eventoId);
    });
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart(Ticket ticket) {
    print('Añadiendo ticket al carrito: ${ticket.name}');
    Provider.of<TicketProvider>(context, listen: false).addTicket(ticket);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text('Boleto agregado al carrito'),
          ],
        ),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Color.fromARGB(255, 0, 81, 118),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Carrito(userId: widget.userId)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: modoFondo ? black : white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130.0),
        child: Stack(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              toolbarHeight: 80,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              title: Text(
                'Detalles de Evento',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
            Positioned(
              top: 85,
              left: 0,
              right: 0,
              child: NabTop(selectedIndexNotifier: _selectedSectionNotifier),
            ),
          ],
        ),
      ),
      body: FutureBuilder<DetallesEvento>(
        future: futureEvento,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Evento no encontrado'));
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ValueListenableBuilder<int>(
                    valueListenable: _selectedSectionNotifier,
                    builder: (context, selectedIndex, child) {
                      return _getSectionContent(
                          selectedIndex,
                          futureEvento,
                          widget.eventoId,
                          widget.userId,
                          _addToCart,
                          _decreaseQuantity,
                          _quantity,
                          _increaseQuantity);
                    },
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

Widget _getSectionContent(
    int selectedIndex,
    Future<DetallesEvento> futureEvento,
    int eventoId,
    int userId,
    Function(Ticket ticket) onAddToCart,
    Function() decre,
    int quantity,
    Function() increaseQuantity) {
  switch (selectedIndex) {
    case 0:
      return DetallesEventContent(
        detallesEventFuture: futureEvento,
        onAddToCart: onAddToCart,
        decre: decre,
        quantity: quantity,
        increaseQuantity: increaseQuantity,
      );
    case 1:
      return Comentarios(
        eventoId: eventoId,
        userId: userId,
      );
    case 2:
      return AsientosScreen(
        eventoId: eventoId,
        userId: userId,
      );
    default:
      return DetallesEventContent(
        detallesEventFuture: futureEvento,
        onAddToCart: onAddToCart,
        decre: decre,
        quantity: quantity,
        increaseQuantity: increaseQuantity,
      );
  }
}

// ignore: must_be_immutable
class DetallesEventContent extends StatelessWidget {
  final Future<DetallesEvento> detallesEventFuture;
  final Function(Ticket ticket) onAddToCart;
  final Function() decre;
  int quantity = 1;
  final Function() increaseQuantity;

  DetallesEventContent(
      {super.key,
      required this.detallesEventFuture,
      required this.onAddToCart,
      required this.decre,
      required this.quantity,
      required this.increaseQuantity});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<DetallesEvento>(
          future: detallesEventFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData) {
              return noInternet();
            } else {
              return _DetalleEvento(snapshot.data!, context);
            }
          },
        ),
      ],
    );
  }

  Widget _DetalleEvento(DetallesEvento evento, context) {
    final _colorDEH = Color.fromARGB(255, 58, 18, 74);
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.0).withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                evento.imagen_url ?? 'no disponible',
                fit: BoxFit.cover,
                width: 300.0,
                height: 250.0,
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: _colorDEH,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.0).withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            width: 350,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text('Evento: ${evento.nombre_evento}',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Organizador: ${evento.organizador_nombre}',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Descripción: ',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          Text(evento.descripcion ?? "No hay descripción",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Fecha inicio: ${evento.fecha_inicio != null ? DateFormat('yyyy-MM-dd').format(evento.fecha_inicio!) : 'Fecha no disponible'}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Fin del evento: ${evento.fecha_termino != null ? DateFormat('yyyy-MM-dd').format(evento.fecha_termino!) : 'Fecha no disponible'}',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Hora: ${evento.hora}',
                            style: GoogleFonts.montserrat(
                                color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Precio: ${tipoPago(evento.precio!)}',
                            style: GoogleFonts.montserrat(
                                color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Categoría: ${evento.categoria_nombre}',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 15)),
                          SizedBox(
                            height: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ubicación:',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text('${evento.ubicacion}',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 14)),
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //AGREGAR BOLETO
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromARGB(255, 9, 143, 13)
                                              .withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ],
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Ticket ticket = Ticket(
                                            id: evento.evento_id!,
                                            name: evento.nombre_evento!,
                                            imagenUrl: evento.imagen_url!,
                                            fechaInicio: evento.fecha_inicio!,
                                            tipoEvento: evento.tipo_evento!,
                                            organizador:
                                                evento.organizador_nombre!,
                                            precio: evento.precio!,
                                            asiento: "B1",
                                            quantity: 1);
                                        onAddToCart(ticket);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 9, 143, 13),
                                        side: const BorderSide(
                                            color:
                                                Color.fromARGB(255, 9, 143, 13),
                                            width: 0.6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25, vertical: 5),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            topRight: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Agregar Boleto',
                                            style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(
                                            Icons.shopping_cart,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //ACTIVAR NOTIFICACIONES
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.2),
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
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                            color: Colors.white, width: 0.6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 4),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.notifications_active,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
