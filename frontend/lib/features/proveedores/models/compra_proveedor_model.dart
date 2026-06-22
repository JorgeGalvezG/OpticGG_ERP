class CompraProveedor {
  final int id;
  final int proveedorId;
  final String? titulo;
  final double monto;
  final double montoPagado;
  final double montoSaldo;
  final String estadoPago;
  final String estadoEntrega;
  final String fechaPedido;
  final String? fechaEntrega;
  final String descripcion;
  final String tienda;
  final List<CompraDetalle>? detalles;

  CompraProveedor({
    required this.id,
    required this.proveedorId,
    this.titulo,
    required this.monto,
    required this.montoPagado,
    required this.montoSaldo,
    required this.estadoPago,
    required this.estadoEntrega,
    required this.fechaPedido,
    this.fechaEntrega,
    required this.descripcion,
    required this.tienda,
    this.detalles,
  });

  factory CompraProveedor.fromJson(Map<String, dynamic> json) {
    return CompraProveedor(
      id: json['id'],
      proveedorId: json['proveedor'] != null ? json['proveedor']['id'] : 0,
      titulo: json['titulo'],
      monto: (json['monto'] as num).toDouble(),
      montoPagado: (json['montoPagado'] as num? ?? 0).toDouble(),
      montoSaldo: (json['montoSaldo'] as num? ?? 0).toDouble(),
      estadoPago: json['estadoPago'] ?? 'PENDIENTE',
      estadoEntrega: json['estadoEntrega'] ?? 'SOLICITADO',
      fechaPedido: json['fechaPedido'] ?? '',
      fechaEntrega: json['fechaEntrega'],
      descripcion: json['descripcion'] ?? '',
      tienda: json['tienda'] ?? '',
      detalles: json['detalles'] != null 
        ? (json['detalles'] as List).map((i) => CompraDetalle.fromJson(i)).toList()
        : null,
    );
  }
}

class CompraDetalle {
  final int id;
  final int? almacenId;
  final String? productoNombre;
  final int cantidad;
  final double precioUnitario;

  CompraDetalle({
    required this.id,
    this.almacenId,
    this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
  });

  factory CompraDetalle.fromJson(Map<String, dynamic> json) {
    return CompraDetalle(
      id: json['id'],
      almacenId: json['almacen'] != null ? json['almacen']['id'] : null,
      productoNombre: json['productoNombre'] ?? (json['almacen'] != null ? json['almacen']['nombre'] : 'Gasto Directo'),
      cantidad: json['cantidad'],
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
    );
  }
}
