import '../models/events.dart';
import '../services/events_services.dart';

class EventsRepository {
  final EventsService _eventsService = EventsService();

  Future<List<ListEvents>> getEvents() {
    return _eventsService.fetchEvents();
  }

  Future<List<ListEvents>> filterEvents(
      String categoria, String tipoEvento, String hora) {
    return _eventsService.getFilteredEvents(categoria, tipoEvento, hora);
  }

  Future<List<ListEvents>> filterEventsName(String nombre) {
    return _eventsService.getFilterNameEvents(nombre);
  }

  Future<List<ListEvents>> filterEventsByType(String tipoEvento) {
    return _eventsService.getFilteredEventsByType(tipoEvento);
  }
}
