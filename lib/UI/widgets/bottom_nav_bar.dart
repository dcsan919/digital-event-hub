import 'package:deh_client/UI/screens/list_events.dart';
import 'package:flutter/material.dart';

class NabInf extends StatefulWidget {
  const NabInf({super.key, required token});

  @override
  State<NabInf> createState() => _NabInfState();
}

class _NabInfState extends State<NabInf> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    ListEvent(),
    Text('Compras'),
    Text("Mapa"),
    Text("Notificaciones"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.trolley),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
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
