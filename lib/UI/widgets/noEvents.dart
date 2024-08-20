import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget noEvents(String text) {
  return Center(
    child: Container(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text(text, style: GoogleFonts.montserrat(fontSize: 19)),
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
