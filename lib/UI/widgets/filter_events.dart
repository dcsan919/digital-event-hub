import 'package:flutter/material.dart';

void showFilterDialog(
  BuildContext context,
  Function(String?, String?, String?) onApplyFilters,
  Function(String?) tipoEvento, {
  String? initialCategoria,
  String? initialTipoEvento,
  String? initialHora,
}) {
  TextEditingController _categoriaController =
      TextEditingController(text: initialCategoria);
  TextEditingController _tipoEventoController =
      TextEditingController(text: initialTipoEvento);
  TextEditingController _horaController =
      TextEditingController(text: initialHora);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            title: Text("Seleccionar Filtros"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Categoria",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 0.2,
                        indent: 0,
                        endIndent: 0,
                      )
                    ],
                  ),
                  subtitle: DropdownButton<String>(
                    hint: Text("Selecciona una categoria"),
                    value: _categoriaController.text.isEmpty
                        ? null
                        : _categoriaController.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        _categoriaController.text = newValue ?? '';
                      });
                    },
                    items: <String>['Tecnologia', 'Artes', 'Deportes']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                    underline: Container(),
                  ),
                ),
                ListTile(
                  title: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tipo de Evento",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 0.2,
                        indent: 0,
                        endIndent: 0,
                      )
                    ],
                  ),
                  subtitle: DropdownButton<String>(
                    hint: Text("Selecciona un Tipo de"),
                    value: _tipoEventoController.text.isEmpty
                        ? null
                        : _tipoEventoController.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        _tipoEventoController.text = newValue ?? '';
                      });
                    },
                    items: <String>['Publico', 'Privado']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                    underline: Container(),
                  ),
                ),
                ListTile(
                  title: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hora",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 0.2,
                        indent: 0,
                        endIndent: 0,
                      )
                    ],
                  ),
                  subtitle: DropdownButton<String>(
                    hint: Text("Selecciona una hora"),
                    value: _horaController.text.isEmpty
                        ? null
                        : _horaController.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        _horaController.text = newValue ?? '';
                      });
                    },
                    items: <String>['09:00:00', '12:00:00', '13:00:00']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                    underline: Container(),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Aplicar"),
                onPressed: () {
                  onApplyFilters(
                      _categoriaController.text.isNotEmpty
                          ? _categoriaController.text
                          : null,
                      _tipoEventoController.text.isNotEmpty
                          ? _tipoEventoController.text
                          : null,
                      _horaController.text.isNotEmpty
                          ? _horaController.text
                          : null);
                  tipoEvento(_tipoEventoController.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
