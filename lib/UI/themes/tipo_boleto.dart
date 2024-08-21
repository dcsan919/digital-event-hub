import 'package:flutter/material.dart';

Color getIconColor(String tipoEvento) {
  if (tipoEvento == 'Privado') {
    return Color.fromARGB(255, 255, 215, 0);
  } else if (tipoEvento == 'Publico') {
    return Color.fromARGB(255, 0, 255, 8);
  } else {
    return Colors.grey;
  }
}

dynamic tipoPago(int precio) {
  if (precio != 0) {
    return "\$${precio}";
  } else {
    return "Gratis";
  }
}

Color getTextoColor(String tipoEvento) {
  if (tipoEvento == 'Privado') {
    return Color.fromARGB(255, 255, 215, 0);
  } else if (tipoEvento == 'Publico') {
    return Color.fromARGB(255, 255, 255, 255);
  } else {
    return Color.fromARGB(255, 255, 0, 0);
  }
}
