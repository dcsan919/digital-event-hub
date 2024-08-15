import 'package:deh_client/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroOrganizador extends StatefulWidget {
  const RegistroOrganizador({Key? key}) : super(key: key);

  @override
  _RegistroOrganizadorState createState() => _RegistroOrganizadorState();
}

class _RegistroOrganizadorState extends State<RegistroOrganizador> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();

  final int _selectedRolId = 2; // Default role ID (Admin)
  final int _selectedMembresiaId = 1; // Default membership ID (4)

  Future<void> _register() async {
    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      _showErrorDialog('Las contraseñas no coinciden');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.96.1:5000/api/register'), // Reemplaza con tu IP local
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': _nombreController.text,
          'email': _emailController.text,
          'password': _contrasenaController.text,
          'phone': int.parse(_telefonoController.text),
          'role_id': _selectedRolId,
          'membresia_id': _selectedMembresiaId,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Error en el registro');
      }
    } catch (error) {
      _showErrorDialog('Error en el registro: $error');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registro Exitoso'),
          content: const Text('El usuario ha sido registrado exitosamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()), // Asegúrate de que Login está definido
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF7F5FC1)), // Color igual al login
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7F5FC1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Login()), // Navega a la pantalla de inicio de sesión
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFF7F5FC1), // Color igual al login
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: width,
              height: height * 0.3,
              color: const Color(0xFF7F5FC1), // Color igual al login
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/images/logo.png',
                    width: 200,
                    height: 150,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: width * 0.8,
                    height: 2,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              width: width,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          "Registro",
                          style: TextStyle(
                            color: Color(0xFF7F5FC1), // Color igual al login
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: width * 0.4,
                          height: 2,
                          color: Color(0xFF7F5FC1), // Color igual al login
                        ),
                        const SizedBox(height: 20),
                        _buildTextInput(
                          controller: _nombreController,
                          icon: Icons.person,
                          hint: "Nombre",
                        ),
                        const SizedBox(height: 20),
                        _buildTextInput(
                          controller: _telefonoController,
                          icon: Icons.phone,
                          hint: "Teléfono",
                        ),
                        const SizedBox(height: 20),
                        _buildTextInput(
                          controller: _emailController,
                          icon: Icons.email,
                          hint: "Correo Electrónico",
                        ),
                        const SizedBox(height: 20),
                        _buildTextInput(
                          controller: _contrasenaController,
                          icon: Icons.lock,
                          hint: "Contraseña",
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextInput(
                          controller: _confirmarContrasenaController,
                          icon: Icons.lock,
                          hint: "Confirmar Contraseña",
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7F5FC1), // Color igual al login
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          ),
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
