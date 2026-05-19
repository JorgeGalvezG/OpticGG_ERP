class Proveedor {
  final int? id;
  final String nombreEmpresa;
  final String? nombreContacto;
  final String? telefono;
  final String? ruc;
  final String tienda;

  Proveedor({
    this.id,
    required this.nombreEmpresa,
    this.nombreContacto,
    this.telefono,
    this.ruc,
    required this.tienda,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombreEmpresa: json['nombreEmpresa'] ?? 'Sin Nombre',
      nombreContacto: json['nombreContacto'],
      telefono: json['telefono'],
      ruc: json['ruc'],
      tienda: json['tienda'] ?? 'C1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreEmpresa': nombreEmpresa,
      'nombreContacto': nombreContacto,
      'telefono': telefono,
      'ruc': ruc,
      'tienda': tienda,
    };
  }
}