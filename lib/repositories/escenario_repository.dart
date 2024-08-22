import 'package:deh_client/models/escenario.dart';
import 'package:deh_client/services/escenario_service.dart';

class EscenarioRepository {
  final EscenarioService _escenarioService = EscenarioService();

  Future<List<Escenario>> getEscenarios() {
    return _escenarioService.fetchEscenario();
  }
}
