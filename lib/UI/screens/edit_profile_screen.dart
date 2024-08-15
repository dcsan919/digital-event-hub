import 'package:flutter/material.dart';
import 'package:deh_client/repositories/usuario_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../models/usuario.dart';
import '../widgets/fotoPerfil.dart';

class EditProfileScreen extends StatefulWidget {
  final Usuario usuario;
  final int userId;

  EditProfileScreen({required this.usuario, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UsuarioRepository usuarioRepository = UsuarioRepository();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _lastNameController;
  late TextEditingController _telefonoController;
  late Future<Usuario> futureUser;
  String? _imageFile;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _lastNameController = TextEditingController(text: widget.usuario.lastName);
    _telefonoController = TextEditingController(text: widget.usuario.telefono);
    _imageFile = widget.usuario.fotoPerfil;
    _fetchUsuario();
  }

  void _fetchUsuario() {
    futureUser = usuarioRepository.getUserById(widget.userId);
  }

  void _changeProfilePicture() {
    showDialog(
      context: context,
      builder: (context) {
        return ChangeProfilePictureModal(
          title: 'Cambiar Foto de Perfil',
          actions: [
            ActionItem(
              icon: Icons.photo,
              text: 'Seleccionar desde galería',
              source: ActionSource.gallery,
              onImageSelected: (String imageFile) async {
                if (await File(imageFile).exists()) {
                  await _updateProfilePicture(imageFile);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Archivo de imagen no encontrado')),
                  );
                }
              },
            ),
            ActionItem(
              icon: Icons.camera_alt,
              text: 'Tomar foto',
              source: ActionSource.camera,
              onImageSelected: (String imageFile) async {
                if (await File(imageFile).exists()) {
                  await _updateProfilePicture(imageFile);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Archivo de imagen no encontrado')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfilePicture(String imageFile) async {
    try {
      await usuarioRepository.uploadProfilePicture(imageFile, widget.userId);
      if (!mounted) return;
      setState(() {
        _imageFile = imageFile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto de perfil actualizada exitosamente')),
      );
      Navigator.of(context).pop();
      _fetchUsuario();
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la foto de perfil')),
        );
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateUsuario() async {
    final response = await http.put(
      Uri.parse(
          'https://api-digitalevent.onrender.com/api/users/${widget.usuario.usuarioId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'nombre': _nombreController.text,
        'last_name': _lastNameController.text,
        'telefono': _telefonoController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Perfil actualizado')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al actualizar perfil: ${response.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<Usuario>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return Center(child: Text('No se encontraron datos del usuario.'));
          } else {
            final usuario = snapshot.data!;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundImage: _imageFile != null
                                  ? (usuario.fotoPerfil != null &&
                                          usuario.fotoPerfil!.isNotEmpty
                                      ? NetworkImage(usuario.fotoPerfil!)
                                      : null)
                                  : FileImage(File(
                                      _imageFile!)), // Mostrar imagen local si se seleccionó una
                              child: (_imageFile == null &&
                                      (usuario.fotoPerfil == null ||
                                          usuario.fotoPerfil!.isEmpty))
                                  ? Icon(Icons.account_circle, size: 160)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 15,
                              child: GestureDetector(
                                onTap: _changeProfilePicture,
                                child: const CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(172, 0, 0, 0),
                                    radius: 20,
                                    child: Icon(Icons.camera_alt,
                                        size: 25,
                                        color:
                                            Color.fromARGB(255, 217, 0, 255))),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.person,
                                color: const Color.fromARGB(255, 150, 11, 145)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su nombre';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Apellido',
                            prefixIcon: Icon(Icons.person_outline,
                                color: const Color.fromARGB(255, 150, 11, 145)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su apellido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _telefonoController,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: Icon(Icons.phone,
                                color: const Color.fromARGB(255, 150, 11, 145)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su teléfono';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateUsuario();
                        }
                      },
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Color.fromARGB(255, 150, 11, 145),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
