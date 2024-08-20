import 'package:deh_client/repositories/usuario_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/usuario.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUsuario();
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

  void _showFullProfilePicture(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Color.fromARGB(159, 0, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRect(
                child: Container(
                  width: double.infinity,
                  child: Center(
                    child: usuario.fotoPerfil != null
                        ? Image.network(
                            usuario.fotoPerfil!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.account_circle,
                            size: double.infinity,
                            color: Colors.grey[700],
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Perfil de Usuario',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
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
            return Center(child: Text('Error al cargar datos del usuario'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No se encontraron datos del usuario.'));
          } else {
            final usuario = snapshot.data!;
            return Stack(
              children: [
                Container(
                  height: 355,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 134, 24, 153),
                        Color.fromARGB(255, 58, 18, 74).withOpacity(1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    /*borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),*/
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
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 15,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(
                                  backgroundImage: usuario.fotoPerfil != null
                                      ? NetworkImage(usuario.fotoPerfil!)
                                      : null,
                                  backgroundColor: Colors.white,
                                  child: usuario.fotoPerfil == null
                                      ? Icon(Icons.account_circle,
                                          size: 50, color: Colors.grey[700])
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    _showFullProfilePicture(usuario);
                                  },
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.7),
                                    radius: 25,
                                    child: Icon(Icons.remove_red_eye,
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
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 325,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 177, 6, 171),
                          Color.fromARGB(255, 134, 24, 153),
                          Color.fromARGB(255, 58, 18, 74),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: ListView(
                          children: [
                            _buildInfoCard(
                                Icons.person, 'Nombre', usuario.nombre),
                            _buildInfoCard(Icons.person_2_outlined, 'Apellido',
                                usuario.lastName),
                            _buildInfoCard(
                                Icons.phone, 'Teléfono', usuario.telefono),
                            _buildInfoCard(Icons.email, 'Correo Electrónico',
                                usuario.email),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: FloatingActionButton.extended(
                      onPressed: () => _editProfile(usuario),
                      icon: Icon(Icons.edit, color: Colors.white),
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

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.white, width: 0.2),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500, color: Colors.white)),
        subtitle:
            Text(subtitle, style: GoogleFonts.montserrat(color: Colors.white)),
      ),
    );
  }
}
