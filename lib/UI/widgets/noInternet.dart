import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget noInternet() {
  return Center(
    child: Container(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text('Sin conexión a internet...',
              style: GoogleFonts.montserrat(fontSize: 19)),
          SizedBox(
            height: 10,
          ),
          Icon(
            Icons.signal_wifi_statusbar_connected_no_internet_4,
            size: 30,
          )
        ],
      ),
    ),
  );
}
