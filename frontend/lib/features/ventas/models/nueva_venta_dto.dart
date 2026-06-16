class NuevaVentaDTO {
  final int pacienteId;
  final int vendedorId;
  final String tienda;
  final String tipoVenta; // ORDEN_TRABAJO o ORDEN_VENTA

  // Finanzas
  final double montoTotal;
  final double montoACuenta;
  final String metodoPago;

  // Datos para ORDEN_TRABAJO
  final String? graduacionOd;
  final String? avOd;
  final String? graduacionOi;
  final String? avOi;
  final String? adicion;
  final String? dip;
  final bool? esLunaCliente;
  final String? tipoLuna;
  final bool? esMonturaCliente;
  final String? montura;
  final String? observaciones;

  // Datos para ORDEN_VENTA (Productos)
  final List<DetalleVentaAlmacenDTO>? productos;

  NuevaVentaDTO({
    required this.pacienteId,
    required this.vendedorId,
    required this.tienda,
    required this.tipoVenta,
    required this.montoTotal,
    required this.montoACuenta,
    required this.metodoPago,
    this.graduacionOd,
    this.avOd,
    this.graduacionOi,
    this.avOi,
    this.adicion,
    this.dip,
    this.esLunaCliente,
    this.tipoLuna,
    this.esMonturaCliente,
    this.montura,
    this.observaciones,
    this.productos,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'pacienteId': pacienteId,
      'vendedorId': vendedorId,
      'tienda': tienda,
      'tipoVenta': tipoVenta,
      'montoTotal': montoTotal,
      'montoACuenta': montoACuenta,
      'metodoPago': metodoPago,
    };

    if (tipoVenta == 'ORDEN_TRABAJO') {
      map.addAll({
        'graduacionOd': graduacionOd ?? '',
        'avOd': avOd ?? '',
        'graduacionOi': graduacionOi ?? '',
        'avOi': avOi ?? '',
        'adicion': adicion ?? '',
        'dip': dip ?? '',
        'esLunaCliente': esLunaCliente ?? false,
        'tipoLuna': tipoLuna ?? '',
        'esMonturaCliente': esMonturaCliente ?? false,
        'montura': montura ?? '',
        'observaciones': observaciones ?? '',
      });
    } else {
      map['productos'] = productos?.map((p) => p.toJson()).toList();
    }

    return map;
  }
}

class DetalleVentaAlmacenDTO {
  final int almacenId;
  final int cantidad;
  final double precioUnitario;

  DetalleVentaAlmacenDTO({
    required this.almacenId,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toJson() => {
    'almacenId': almacenId,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
  };
}