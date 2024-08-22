import 'package:deh_client/UI/themes/cambiar_modo.dart';
import 'package:flutter/material.dart';
import 'package:deh_client/repositories/asiento_repository.dart';
import 'package:deh_client/models/asientos.dart';
import 'package:deh_client/repositories/escenario_repository.dart';
import 'package:deh_client/models/escenario.dart';
import 'package:google_fonts/google_fonts.dart';

class AsientosScreen extends StatefulWidget {
  final int eventoId;
  final int userId;

  const AsientosScreen({
    super.key,
    required this.eventoId,
    required this.userId,
  });

  @override
  State<AsientosScreen> createState() => _AsientosScreenState();
}

class _AsientosScreenState extends State<AsientosScreen> {
  final AsientoRepository asientoRepository = AsientoRepository();
  final EscenarioRepository escenarioRepository = EscenarioRepository();
  late Future<List<Escenario>> futureEscenarios;

  @override
  void initState() {
    super.initState();
    _fetchEscenarios();
  }

  void _fetchEscenarios() {
    setState(() {
      futureEscenarios = escenarioRepository.getEscenarios();
    });
  }

  Color _estadoColor(String estado) {
    return estado == 'Reservado' ? Colors.green : Colors.red;
  }

  Widget _asientoWidget(Asientos asiento) {
    final isReserved = asiento.estado == 'Reservado';
    return GestureDetector(
      onTap: () {
        // Lógica para seleccionar un asiento
      },
      child: Container(
        decoration: BoxDecoration(
          color: _estadoColor(asiento.estado!),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: isReserved
              ? CircleAvatar(
                  backgroundImage: NetworkImage('URL_DEL_USUARIO'),
                  backgroundColor: Colors.transparent,
                )
              : Icon(
                  Icons.event_seat,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asientos disponibles',
            style: GoogleFonts.montserrat(
              color: modoFondo ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Adjust height here if needed
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.7, // Adjust as needed
            child: FutureBuilder<List<Escenario>>(
              future: futureEscenarios,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay asientos disponibles.'));
                } else {
                  final escenarios = snapshot.data!;
                  final escenario = escenarios.firstWhere(
                    (esc) => esc.eventoId == widget.eventoId,
                    orElse: () =>
                        Escenario(), // Devuelve un vacío en caso de no encontrar
                  );

                  final asientos =
                      (escenario.asientos as List<Asientos>? ?? []);

                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: asientos.length,
                    itemBuilder: (context, index) {
                      final asiento = asientos[index];
                      return _asientoWidget(asiento);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
