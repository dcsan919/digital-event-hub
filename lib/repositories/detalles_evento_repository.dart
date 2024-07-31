import 'package:deh_client/services/detalle_evento_service.dart';
import '../models/detalles-evento.dart';

class DetallesEventoRepository {
  final DetalleEventoService _detalleEventoService = DetalleEventoService();

  Future<DetallesEvento> getEventById(int eventoId) {
    return _detalleEventoService.fetchEventsById(eventoId);
  }
}
