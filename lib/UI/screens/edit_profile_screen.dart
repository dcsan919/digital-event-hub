import 'package:deh_client/UI/themes/linea.dart';
import 'package:flutter/material.dart';
import 'package:deh_client/repositories/usuario_repository.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String? imageFiles;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _lastNameController = TextEditingController(text: widget.usuario.lastName);
    _telefonoController = TextEditingController(text: widget.usuario.telefono);
    imageFiles = widget.usuario.fotoPerfil;
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
        imageFiles = imageFile;
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Editar Perfil',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                Form(
                  key: _formKey,
                  child: Column(children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 360,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 134, 24, 153),
                                Color.fromARGB(255, 58, 18, 74).withOpacity(1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 250,
                              child: Center(
                                child: Align(
                                  alignment: Alignment(0.0, 1.5),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              spreadRadius: 7,
                                              blurRadius: 15,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          backgroundImage:
                                              usuario.fotoPerfil != null
                                                  ? NetworkImage(
                                                      usuario.fotoPerfil!)
                                                  : null,
                                          backgroundColor: Colors.white,
                                          child: usuario.fotoPerfil == null
                                              ? Icon(Icons.account_circle,
                                                  size: 50,
                                                  color: Colors.grey[700])
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            _changeProfilePicture();
                                          },
                                          child: CircleAvatar(
                                            backgroundColor:
                                                Colors.black.withOpacity(0.7),
                                            radius: 25,
                                            child: Icon(Icons.camera_alt,
                                                size: 30, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Text("Editar Información",
                              style: GoogleFonts.montserrat(fontSize: 18)),
                          SizedBox(height: 10),
                          CustomDivider(height: 1.5, width: 250),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _nombreController,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              labelStyle: GoogleFonts.montaga(),
                              prefixIcon: Icon(Icons.person,
                                  color:
                                      const Color.fromARGB(255, 150, 11, 145)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: GoogleFonts.montaga(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su nombre';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Apellido',
                              labelStyle: GoogleFonts.montaga(),
                              prefixIcon: Icon(Icons.person_outline,
                                  color:
                                      const Color.fromARGB(255, 150, 11, 145)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: GoogleFonts.montaga(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su apellido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _telefonoController,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.montaga(),
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone,
                                  color:
                                      const Color.fromARGB(255, 150, 11, 145)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: GoogleFonts.montaga(),
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
                    )
                  ]),
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
