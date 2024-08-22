import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/usuario_screen.dart';
import 'package:deh_client/repositories/usuario_repository.dart';
import '../../models/usuario.dart';
import '../../UI/themes/cambiar_modo.dart';

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

  void _modoFondo() {
    setState(() {
      modoFondo = !modoFondo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: modoFondo ? Colors.black : Colors.white,
      child: Container(
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
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 7,
                                  blurRadius: 15,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: usuario.fotoPerfil != null
                                  ? NetworkImage(usuario.fotoPerfil!)
                                  : null,
                              child: usuario.fotoPerfil == null
                                  ? Icon(Icons.account_circle,
                                      size: 50, color: Colors.grey[700])
                                  : null,
                            ),
                          ),
                          SizedBox(height: 8),
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
                style: GoogleFonts.montserrat(
                    color: modoFondo ? Colors.white : Colors.black),
              ),
              tileColor: modoFondo ? Colors.black : Colors.grey[200],
            ),
            Divider(),
            _listTitle(Icons.person, 'Perfil Usuarioo', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UsuarioScreen(
                          userId: widget.userId,
                          usuario: widget.usuario,
                        )),
              );
            }),
            _listTitle(
                Icons.settings, 'Configuración', () => Navigator.pop(context)),
            _listTitle(Icons.support, 'Soporte y capacitación',
                () => Navigator.pop(context)),
            _listTitle(
                Icons.tune, 'Optimización', () => Navigator.pop(context)),
            _listTitle(Icons.info, 'Acerca de', () => Navigator.pop(context)),
            SizedBox(
              height: 100,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      _modoFondo();
                    },
                    icon: modoFondo
                        ? Icon(
                            Icons.nightlight,
                            size: 35,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.light_mode,
                            size: 35,
                          )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTitle(IconData icon, String text, Function() navigator) {
    return ListTile(
        leading: Icon(
          icon,
          color: modoFondo ? Colors.white : Colors.black,
        ),
        title: Text(
          text,
          style: GoogleFonts.montserrat(
              color: modoFondo ? Colors.white : Colors.black),
        ),
        onTap: navigator);
  }
}
