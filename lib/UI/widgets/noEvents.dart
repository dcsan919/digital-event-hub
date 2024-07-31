import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget noEvents() {
  return Center(
    child: Container(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text('No se encontraron eventos',
              style: GoogleFonts.montserrat(fontSize: 19)),
          SizedBox(
            height: 10,
          ),
          Icon(
            Icons.search_off,
            size: 40,
          ),
        ],
      ),
    ),
  );
}
