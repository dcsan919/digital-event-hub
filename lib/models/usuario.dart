class Usuario {
  final int usuarioId;
  final String nombre;
  final String email;
  final String contrasena;
  final String telefono;
  final int rolId;
  final int? membresiaId;
  final int activo;
  final String lastName;
  final String? resetPasswordExpire;
  final String? resetPasswordToken;
  final String? fotoPerfil;

  Usuario({
    required this.usuarioId,
    required this.nombre,
    required this.email,
    required this.contrasena,
    required this.telefono,
    required this.rolId,
    this.membresiaId,
    required this.activo,
    required this.lastName,
    this.resetPasswordExpire,
    this.resetPasswordToken,
    this.fotoPerfil,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      email: json['email'],
      contrasena: json['contrasena'],
      telefono: json['telefono'],
      rolId: json['rol_id'],
      membresiaId: json['membresia_id'],
      activo: json['activo'],
      lastName: json['last_name'],
      resetPasswordExpire: json['resetPasswordExpire'],
      resetPasswordToken: json['resetPasswordToken'],
      fotoPerfil: json['fotoPerfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre': nombre,
      'email': email,
      'contrasena': contrasena,
      'telefono': telefono,
      'rol_id': rolId,
      'membresia_id': membresiaId,
      'activo': activo,
      'last_name': lastName,
      'resetPasswordExpire': resetPasswordExpire,
      'resetPasswordToken': resetPasswordToken,
      'fotoPerfil': fotoPerfil,
    };
  }
}
