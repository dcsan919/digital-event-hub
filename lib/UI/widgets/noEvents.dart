import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/cambiar_modo.dart';

Widget noEvents(String text, IconData icon) {
  return Center(
    child: Container(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text(text,
              style: GoogleFonts.montserrat(
                  fontSize: 19, color: modoFondo ? white : black)),
          SizedBox(
            height: 10,
          ),
          Icon(
            icon,
            size: 40,
            color: modoFondo ? white : black,
          ),
        ],
      ),
    ),
  );
}
