import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/usuario_screen.dart';
import 'package:deh_client/repositories/usuario_repository.dart';
import '../../models/usuario.dart';

class Sidebar extends StatefulWidget {
  final int userId;
  final Usuario usuario;

  Sidebar({required this.userId, required this.usuario});
  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final UsuarioRepository usuarioRepository = UsuarioRepository();
  late Future<Usuario> futureUser;

  @override
  void initState() {
    super.initState();
    _fetchUsuario();
  }

  void _fetchUsuario() {
    setState(() {
      futureUser = usuarioRepository.getUserById(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 280.0,
            width: double.infinity,
            child: FutureBuilder<Usuario>(
              future: futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return DrawerHeader(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasData) {
                  final usuario = snapshot.data!;
                  return DrawerHeader(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 239, 3, 211),
                          Color.fromARGB(255, 134, 24, 153),
                          Color.fromARGB(255, 58, 18, 74)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: usuario.fotoPerfil != null
                              ? NetworkImage(usuario.fotoPerfil!)
                              : null,
                          child: usuario.fotoPerfil == null
                              ? Icon(Icons.account_circle,
                                  size: 50, color: Colors.grey[700])
                              : null,
                        ),
                        SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            '${usuario.nombre} ${usuario.lastName}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox(); // Default widget if there's no data
              },
            ),
          ),
          ListTile(
            title: Text(
              'Menú',
              style: GoogleFonts.montserrat(), // Aplicar Google Fonts
            ),
            tileColor: Colors.grey[200],
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Perfil Usuario',
              style: GoogleFonts.montserrat(), // Aplicar Google Fonts
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UsuarioScreen(
                          userId: widget.userId,
                          usuario: widget.usuario,
                        )),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              'Configuración',
              style: GoogleFonts.montserrat(), // Aplicar Google Fonts
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.support),
            title: Text(
              'Soporte y capacitación',
              style: GoogleFonts.montserrat(), // Aplicar Google Fonts
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.tune),
            title: Text(
              'Optimización',
              style: GoogleFonts.montserrat(), // Aplicar Google Fonts
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(
              'Acerca de',
              style: GoogleFonts.montserrat(), // Aplicar Google Fonts
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
