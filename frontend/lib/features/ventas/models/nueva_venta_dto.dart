class NuevaVentaDTO {
  final int pacienteId;
  final int vendedorId;
  final String tienda;

  // Finanzas
  final double montoTotal;
  final double montoACuenta;

  // Receta
  final String graduacionOd;
  final String graduacionOi;
  final String adicion;
  final String dip;

  // Productos
  final bool esLunaCliente;
  final String tipoLuna;
  final bool esMonturaCliente;
  final String montura;
  final String observaciones;

  final String metodoPago;

  NuevaVentaDTO({
    required this.pacienteId,
    required this.vendedorId,
    required this.tienda,
    required this.montoTotal,
    required this.montoACuenta,
    required this.graduacionOd,
    required this.graduacionOi,
    required this.adicion,
    required this.dip,
    required this.esLunaCliente,
    required this.tipoLuna,
    required this.esMonturaCliente,
    required this.montura,
    required this.observaciones,
    required this.metodoPago,
  });

  // Solo necesitamos el toJson porque esto va de Flutter hacia Java
  Map<String, dynamic> toJson() {
    return {
      'pacienteId': pacienteId,
      'vendedorId': vendedorId,
      'tienda': tienda,
      'montoTotal': montoTotal,
      'montoACuenta': montoACuenta,
      'graduacionOd': graduacionOd,
      'graduacionOi': graduacionOi,
      'adicion': adicion,
      'dip': dip,
      'esLunaCliente': esLunaCliente,
      'tipoLuna': tipoLuna,
      'esMonturaCliente': esMonturaCliente,
      'montura': montura,
      'observaciones': observaciones,
      'metodoPago': metodoPago,
    };
  }
}