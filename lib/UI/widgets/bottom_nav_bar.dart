import 'package:flutter/material.dart';
import '../screens/compras_screen.dart';
import '../screens/notificaciones_screen.dart';
import '../screens/map_screen.dart';
import '../../models/usuario.dart';
import '../screens/list_events.dart';
import 'package:icons_plus/icons_plus.dart';

class NabInf extends StatefulWidget {
  final int userId;
  final Usuario usuario;
  final String token;

  const NabInf(
      {super.key,
      required this.token,
      required this.userId,
      required this.usuario});
  @override
  State<NabInf> createState() => _NabInfState();
}

class _NabInfState extends State<NabInf> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      ListEvent(
        userId: widget.userId,
        usuario: widget.usuario,
      ),
      ComprasScreen(
        userId: widget.userId,
        cart: [],
      ),
      MapScreen(),
      NotificacionesScreen()
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Bootstrap.ticket_detailed_fill,
            ),
            label: 'Boleto',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Bootstrap.map_fill,
            ),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.fromARGB(255, 58, 18, 74),
      ),
    );
  }
}
