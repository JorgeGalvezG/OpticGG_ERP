class NuevaVentaDTO {
  final int? pacienteId;
  final String? pacienteNombreManual;
  final int vendedorId;
  final String tienda;
  final String tipoVenta; // ORDEN_TRABAJO o ORDEN_VENTA
  final String? fechaManual;

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
  final String? tipoLunaOd;
  final double? precioLunaOd;
  final String? tipoLunaOi;
  final double? precioLunaOi;

  final bool? esMonturaCliente;
  final String? montura;
  final double? precioMontura;

  final String? observaciones;
  final String? especialista;

  // Compra Extra fields
  final bool? tieneCompraExtra;
  final String? graduacionOdExtra;
  final String? avOdExtra;
  final String? graduacionOiExtra;
  final String? avOiExtra;
  final String? adicionExtra;
  final String? dipExtra;
  final bool? esLunaClienteExtra;
  final String? tipoLunaExtra;
  final String? tipoLunaOdExtra;
  final double? precioLunaOdExtra;
  final String? tipoLunaOiExtra;
  final double? precioLunaOiExtra;
  final bool? esMonturaClienteExtra;
  final String? monturaExtra;
  final double? precioMonturaExtra;
  final String? observacionesExtra;
  final String? especialistaExtra;

  // Datos para ORDEN_VENTA (Productos)
  final List<DetalleVentaAlmacenDTO>? productos;

  NuevaVentaDTO({
    this.pacienteId,
    this.pacienteNombreManual,
    required this.vendedorId,
    required this.tienda,
    required this.tipoVenta,
    required this.montoTotal,
    required this.montoACuenta,
    required this.metodoPago,
    this.fechaManual,
    this.graduacionOd,
    this.avOd,
    this.graduacionOi,
    this.avOi,
    this.adicion,
    this.dip,
    this.esLunaCliente,
    this.tipoLuna,
    this.tipoLunaOd,
    this.precioLunaOd,
    this.tipoLunaOi,
    this.precioLunaOi,
    this.esMonturaCliente,
    this.montura,
    this.precioMontura,
    this.observaciones,
    this.especialista,
    this.tieneCompraExtra,
    this.graduacionOdExtra,
    this.avOdExtra,
    this.graduacionOiExtra,
    this.avOiExtra,
    this.adicionExtra,
    this.dipExtra,
    this.esLunaClienteExtra,
    this.tipoLunaExtra,
    this.tipoLunaOdExtra,
    this.precioLunaOdExtra,
    this.tipoLunaOiExtra,
    this.precioLunaOiExtra,
    this.esMonturaClienteExtra,
    this.monturaExtra,
    this.precioMonturaExtra,
    this.observacionesExtra,
    this.especialistaExtra,
    this.productos,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'pacienteId': pacienteId,
      'pacienteNombreManual': pacienteNombreManual,
      'vendedorId': vendedorId,
      'tienda': tienda,
      'tipoVenta': tipoVenta,
      'montoTotal': montoTotal,
      'montoACuenta': montoACuenta,
      'metodoPago': metodoPago,
      'fechaManual': fechaManual,
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
        'tipoLunaOd': tipoLunaOd ?? '',
        'precioLunaOd': precioLunaOd ?? 0.0,
        'tipoLunaOi': tipoLunaOi ?? '',
        'precioLunaOi': precioLunaOi ?? 0.0,
        'esMonturaCliente': esMonturaCliente ?? false,
        'montura': montura ?? '',
        'precioMontura': precioMontura ?? 0.0,
        'observaciones': observaciones ?? '',
        'especialista': especialista ?? '',
        'tieneCompraExtra': tieneCompraExtra ?? false,
        'graduacionOdExtra': graduacionOdExtra ?? '',
        'avOdExtra': avOdExtra ?? '',
        'graduacionOiExtra': graduacionOiExtra ?? '',
        'avOiExtra': avOiExtra ?? '',
        'adicionExtra': adicionExtra ?? '',
        'dipExtra': dipExtra ?? '',
        'esLunaClienteExtra': esLunaClienteExtra ?? false,
        'tipoLunaExtra': tipoLunaExtra ?? '',
        'tipoLunaOdExtra': tipoLunaOdExtra ?? '',
        'precioLunaOdExtra': precioLunaOdExtra ?? 0.0,
        'tipoLunaOiExtra': tipoLunaOiExtra ?? '',
        'precioLunaOiExtra': precioLunaOiExtra ?? 0.0,
        'esMonturaClienteExtra': esMonturaClienteExtra ?? false,
        'monturaExtra': monturaExtra ?? '',
        'precioMonturaExtra': precioMonturaExtra ?? 0.0,
        'observacionesExtra': observacionesExtra ?? '',
        'especialistaExtra': especialistaExtra ?? '',
      });
    } else {
      map['productos'] = productos?.map((p) => p.toJson()).toList();
    }

    return map;
  }
}

class DetalleVentaAlmacenDTO {
  final int? almacenId;
  final String? nombreProductoManual;
  final int cantidad;
  final double precioUnitario;

  DetalleVentaAlmacenDTO({
    this.almacenId,
    this.nombreProductoManual,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toJson() => {
    'almacenId': almacenId,
    'nombreProductoManual': nombreProductoManual,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
  };
}
