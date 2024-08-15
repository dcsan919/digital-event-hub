import 'dart:io';
import 'package:deh_client/repositories/usuario_repository.dart';
import '../../models/usuario.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../widgets/fotoPerfil.dart';

class UsuarioScreen extends StatefulWidget {
  final Usuario usuario;
  final int userId;
  UsuarioScreen({required this.userId, required this.usuario});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final UsuarioRepository usuarioRepository = UsuarioRepository();
  late Future<Usuario> futureUser;
  String? _imageFile;

  @override
  void initState() {
    super.initState();
    _imageFile = widget.usuario.fotoPerfil;
    _fetchUsuario();
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
                  setState(() {
                    _imageFile = imageFile;
                  });
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
      setState(() {
        _imageFile = imageFile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto de perfil actualizada exitosamente')),
      );
      _fetchUsuario();
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la foto de perfil')),
      );
    }
  }

  void _fetchUsuario() {
    futureUser = usuarioRepository.getUserById(widget.userId);
  }

  void _editProfile(Usuario usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          usuario: usuario,
          userId: widget.userId,
        ),
      ),
    ).then((_) {
      setState(() {
        _fetchUsuario();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              futureUser.then((usuario) {
                _editProfile(usuario);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Usuario>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text('No se encontraron datos del usuario.'),
            );
          } else {
            final usuario = snapshot.data!;
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                backgroundImage: usuario.fotoPerfil != null
                                    ? NetworkImage(usuario.fotoPerfil!)
                                    : null,
                                radius: 80,
                                backgroundColor: Colors.white,
                                child: usuario.fotoPerfil == null
                                    ? Icon(Icons.account_circle,
                                        size: 50, color: Colors.grey[700])
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
                                          color: Color.fromARGB(
                                              255, 217, 0, 255))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        children: [
                          Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.person,
                                  color:
                                      const Color.fromARGB(255, 150, 11, 145)),
                              title: Text('Nombre'),
                              subtitle: Text(usuario.nombre),
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.person_2_outlined,
                                  color:
                                      const Color.fromARGB(255, 150, 11, 145)),
                              title: Text('Apellido'),
                              subtitle: Text(usuario.lastName),
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.phone,
                                  color:
                                      const Color.fromARGB(255, 150, 11, 145)),
                              title: Text('Teléfono'),
                              subtitle: Text(usuario.telefono),
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.email,
                                  color:
                                      const Color.fromARGB(255, 150, 11, 145)),
                              title: Text('Correo Electrónico'),
                              subtitle: Text(usuario.email),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: FloatingActionButton.extended(
                      onPressed: () => _editProfile(usuario),
                      icon: Icon(Icons.edit,
                          color: const Color.fromARGB(255, 255, 255, 255)),
                      label: Text(
                        'Editar Perfil',
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
