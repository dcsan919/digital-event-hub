import 'package:deh_client/models/asientos.dart';
import 'package:deh_client/services/asiento_services.dart';

class AsientoRepository {
  final AsientoServices _asientoService = AsientoServices();

  Future<List<Asientos>> getAsientos() {
    return _asientoService.fetchAsiento();
  }
}
