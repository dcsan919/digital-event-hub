import 'package:flutter/foundation.dart';
import 'package:deh_client/models/ticket.dart';

class TicketProvider extends ChangeNotifier {
  List<Ticket> _cart = [];

  List<Ticket> get cart => _cart;

  void addTicket(Ticket ticket) {
    _cart.add(ticket);
    notifyListeners();
  }

  void removeTicket(Ticket ticket) {
    _cart.remove(ticket);
    notifyListeners();
  }

  void setCart(List<Ticket> tickets) {
    _cart = tickets;
    notifyListeners();
  }
}
