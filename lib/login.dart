import 'dart:convert';
import 'package:deh_client/UI/widgets/bottom_nav_bar.dart';
import 'package:deh_client/main.dart';
import 'package:deh_client/registro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../models/usuario.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool obscureText = true;

  void _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (_formKey.currentState?.validate() ?? false) {
      final String email = _emailController.text;
      final String password = _passwordController.text;

      _showLoadingDialog();

      try {
        final response = await http.post(
          Uri.parse('https://api-digitalevent.onrender.com/api/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'contrasena': password,
          }),
        );

        Navigator.of(context).pop();

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['token'];
          final userId = data['user']['usuario_id'];
          final userJson = data['user'];

          final usuario = Usuario.fromJson(userJson);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => NabInf(
                      token: token,
                      userId: userId,
                      usuario: usuario,
                    )),
          );
        } else {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error'] ?? 'Error desconocido.';

          _showErrorDialog('Inicio de sesión fallido: $errorMessage');
        }
      } catch (e) {
        _showErrorDialog(
            'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.');
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF3A124A),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(width: 25),
              Text(
                "Iniciando sesión...",
                style:
                    GoogleFonts.montserrat(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Error al iniciar sesión',
            style: GoogleFonts.montserrat(),
          ),
          content: Text(
            message,
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _togglePasswordView() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F35A5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage()), // Navega a la pantalla de inicio
            );
          },
        ),
      ),
      backgroundColor:
          const Color(0xFF6F35A5), // Cambiado a un tono más suave de púrpura
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width * 0.9,
            height: height * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'lib/images/logo2.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Bienvenido",
                    style: GoogleFonts.montserrat(
                      color: Color(0xFF6F35A5),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextInput(
                      icon: Icons.email,
                      hint: "Correo electrónico",
                      controller: _emailController,
                      validation: 'Ingrese su correo'),
                  const SizedBox(height: 20),
                  _buildTextInput(
                    icon: Icons.lock,
                    hint: "Contraseña",
                    obscureText: obscureText,
                    passHide: IconButton(
                      icon: Icon(obscureText
                          ? Icons.remove_red_eye
                          : Icons.visibility_off),
                      color: obscureText ? Color(0xFF6F35A5) : Colors.green,
                      onPressed: () {
                        _togglePasswordView();
                      },
                    ),
                    validation: 'Ingrese su contraseña',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton(
                    onPressed: _login,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F35A5),
                      side: const BorderSide(color: Colors.white, width: 0.6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                    ),
                    child: const Text(
                      "Iniciar sesión",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Registro()),
                      );
                    },
                    child: const Text(
                      "¿No tienes cuenta? ¡Regístrate!",
                      style: TextStyle(
                        color: Color(0xFF6F35A5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required IconData icon,
    required String hint,
    Widget? passHide,
    required TextEditingController controller,
    bool obscureText = false,
    required String validation,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF6F35A5)),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(15),
          suffixIcon: passHide,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validation;
          }
          return null;
        },
      ),
    );
  }
}
