class Paciente {
  final int? id;
  final String nombre;
  final String apellidos;
  final String? telefono; // Puede ser null en tu BD
  final int? edad; // Puede ser null
  final String? fechaNacimiento; // Puede ser null, lo tratamos como String "YYYY-MM-DD"
  final bool esDestacado;
  final String tienda;

  Paciente({
    this.id,
    required this.nombre,
    required this.apellidos,
    this.telefono,
    this.edad,
    this.fechaNacimiento,
    this.esDestacado = false,
    required this.tienda,
  });

  // Leer lo que manda Java
  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      nombre: json['nombre'] ?? 'Sin Nombre',
      apellidos: json['apellidos'] ?? '',
      telefono: json['telefono'], // Permitimos null
      edad: json['edad'],
      fechaNacimiento: json['fechaNacimiento'],
      esDestacado: json['esDestacado'] ?? false,
      tienda: json['tienda'] ?? 'C1',
    );
  }

  // Enviar JSON a Java
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'edad': edad,
      'fechaNacimiento': fechaNacimiento,
      'esDestacado': esDestacado,
      'tienda': tienda,
    };
  }
}