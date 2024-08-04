import 'package:deh_client/UI/screens/comentarios.dart';
import 'package:deh_client/UI/screens/detalles_event.dart';
import 'package:deh_client/UI/screens/list_events.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Event Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ListEvent(),
      routes: {},
    );
  }
}
