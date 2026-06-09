class CategoriaProducto {
  final int id;
  final String nombre;
  final String clasificacion;

  CategoriaProducto({
    required this.id,
    required this.nombre,
    required this.clasificacion,
  });

  factory CategoriaProducto.fromJson(Map<String, dynamic> json) {
    return CategoriaProducto(
      id: json['id'],
      nombre: json['nombre'],
      clasificacion: json['clasificacion'],
    );
  }
}