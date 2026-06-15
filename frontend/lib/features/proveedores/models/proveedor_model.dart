class Proveedor {
  final int? id;
  final String nombreEmpresa;
  final String? ruc;
  final String tienda;
  final List<ProveedorContacto> contactos;

  Proveedor({
    this.id,
    required this.nombreEmpresa,
    this.ruc,
    required this.tienda,
    this.contactos = const [],
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombreEmpresa: json['nombreEmpresa'] ?? 'Sin Nombre',
      ruc: json['ruc'],
      tienda: json['tienda'] ?? 'C1',
      contactos: json['contactos'] != null 
        ? (json['contactos'] as List).map((i) => ProveedorContacto.fromJson(i)).toList()
        : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreEmpresa': nombreEmpresa,
      'ruc': ruc,
      'tienda': tienda,
      'contactos': contactos.map((c) => c.toJson()).toList(),
    };
  }
}

class ProveedorContacto {
  final int? id;
  final String nombre;
  final String? telefono;
  final String? cargo;

  ProveedorContacto({
    this.id,
    required this.nombre,
    this.telefono,
    this.cargo,
  });

  factory ProveedorContacto.fromJson(Map<String, dynamic> json) {
    return ProveedorContacto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'],
      cargo: json['cargo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'cargo': cargo,
    };
  }
}
