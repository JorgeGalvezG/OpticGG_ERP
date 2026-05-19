class Usuario {
  final int? id;
  final String username;
  final String rol;
  final String tienda;
  final bool activo;

  Usuario({
    this.id,
    required this.username,
    required this.rol,
    required this.tienda,
    this.activo = true,
  });

  // Para leer el JSON que nos manda Java
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      username: json['username'] ?? 'Usuario Desconocido',
      rol: json['rol'] ?? 'Sin Rol',
      tienda: json['tienda'] ?? 'Todas',
      activo: json['activo'] ?? true,
    );
  }

  // Para enviar nuestros datos como JSON a Java (POST)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'rol': rol,
      'tienda': tienda,
      'activo': activo,
    };
  }
}