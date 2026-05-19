class MovimientoCaja {
  final int id;
  final String tipo; // ENTRADA o SALIDA
  final double monto;
  final String descripcion;
  final String fecha;
  final String usuarioNombre;

  MovimientoCaja({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.usuarioNombre,
  });

  factory MovimientoCaja.fromJson(Map<String, dynamic> json) {
    final usr = json['usuario'] ?? {};
    return MovimientoCaja(
      id: json['id'] ?? 0,
      tipo: json['tipo'] ?? 'ENTRADA',
      monto: (json['monto'] ?? 0).toDouble(),
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
      usuarioNombre: usr['username'] ?? 'Sistema',
    );
  }
}