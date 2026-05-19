class NuevoMovimientoDTO {
  final String tipo;
  final double monto;
  final String descripcion;
  final int usuarioId;
  final String tienda;

  NuevoMovimientoDTO({
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.usuarioId,
    required this.tienda,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'monto': monto,
      'descripcion': descripcion,
      'usuarioId': usuarioId,
      'tienda': tienda,
    };
  }
}