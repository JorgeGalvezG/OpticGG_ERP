class ConfigTienda {
  final String tienda;
  final String nombreOptica;
  final String ruc;
  final String direccion;
  final String telefono;
  final String? logoUrl;

  ConfigTienda({
    required this.tienda,
    required this.nombreOptica,
    required this.ruc,
    required this.direccion,
    required this.telefono,
    this.logoUrl,
  });

  factory ConfigTienda.fromJson(Map<String, dynamic> json) {
    return ConfigTienda(
      tienda: json['tienda'] ?? '',
      nombreOptica: json['nombreOptica'] ?? '',
      ruc: json['ruc'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      logoUrl: json['logoUrl'],
    );
  }
}
