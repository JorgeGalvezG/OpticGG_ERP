class PacienteReactivar {
  final int id;
  final String nombre;
  final String apellidos;
  final String? telefono;
  final String tienda;
  final String fechaUltimaConsulta;

  PacienteReactivar({
    required this.id,
    required this.nombre,
    required this.apellidos,
    this.telefono,
    required this.tienda,
    required this.fechaUltimaConsulta,
  });

  factory PacienteReactivar.fromJson(Map<String, dynamic> json) {
    return PacienteReactivar(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      telefono: json['telefono'],
      tienda: json['tienda'] ?? 'C1',
      fechaUltimaConsulta: json['fechaUltimaConsulta'] ?? '',
    );
  }
}
