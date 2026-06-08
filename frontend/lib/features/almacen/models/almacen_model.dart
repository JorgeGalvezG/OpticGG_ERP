class Almacen {
  final int id;
  final String codigoBarras;
  final String nombre;
  final int categoriaId;
  final String? categoriaNombre;
  final int? proveedorId;
  final String? proveedorNombre;
  final int stock;
  final String fotoUrl;
  final double precioCompra;
  final double precioVenta;
  final String tienda;

  Almacen({
    required this.id,
    required this.codigoBarras,
    required this.nombre,
    required this.categoriaId,
    this.categoriaNombre,
    this.proveedorId,
    this.proveedorNombre,
    required this.stock,
    required this.fotoUrl,
    required this.precioCompra,
    required this.precioVenta,
    required this.tienda,
  });

  factory Almacen.fromJson(Map<String, dynamic> json) {
    return Almacen(
      id: json['id'],
      codigoBarras: json['codigoBarras'],
      nombre: json['nombre'],
      categoriaId: json['categoria'] != null ? json['categoria']['id'] : 0,
      categoriaNombre: json['categoria'] != null ? json['categoria']['nombre'] : null,
      proveedorId: json['proveedor'] != null ? json['proveedor']['id'] : null,
      proveedorNombre: json['proveedor'] != null ? json['proveedor']['nombreEmpresa'] : null,
      stock: json['stock'],
      fotoUrl: json['fotoUrl'] ?? 'default_product.png',
      precioCompra: (json['precioCompra'] as num).toDouble(),
      precioVenta: (json['precioVenta'] as num).toDouble(),
      tienda: json['tienda'],
    );
  }
}