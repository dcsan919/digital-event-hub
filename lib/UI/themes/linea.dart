import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double width;

  CustomDivider(
      {this.color = Colors.black, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyCustomClipper(),
      child: Container(
        color: color,
        height: height,
        width: width,
      ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    double pointHeight = size.height / 2;

    path.lineTo(0, pointHeight);
    path.lineTo(size.width / 4, size.height); // Punto puntiagudo izquierdo
    path.lineTo(3 * size.width / 4, size.height); // Punto puntiagudo derecho
    path.lineTo(size.width, pointHeight);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
