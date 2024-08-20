import 'package:flutter/material.dart';

Color getIconColor(String tipoEvento) {
  if (tipoEvento == 'Privado') {
    return Color.fromARGB(255, 255, 215, 0);
  } else if (tipoEvento == 'Publico') {
    return const Color.fromARGB(255, 33, 133, 36);
  } else {
    return Colors.grey;
  }
}
