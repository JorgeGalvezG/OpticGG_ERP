class PacienteConMedidaDTO {
  final int? id;
  final String nombre;
  final String apellidos;
  final String? dni;
  final String? telefono;
  final int? edad;
  final String? fechaNacimiento;
  final bool esDestacado;
  final String tienda;

  // Medida de vista
  final String? graduacionOd;
  final String? avOd;
  final String? graduacionOi;
  final String? avOi;
  final String? adicion;
  final String? dip;
  final String? tipoLuna;
  final String? montura;
  final String? observaciones;
  final String? especialista;
  final int? vendedorId;

  PacienteConMedidaDTO({
    this.id,
    required this.nombre,
    required this.apellidos,
    this.dni,
    this.telefono,
    this.edad,
    this.fechaNacimiento,
    this.esDestacado = false,
    required this.tienda,
    this.graduacionOd,
    this.avOd,
    this.graduacionOi,
    this.avOi,
    this.adicion,
    this.dip,
    this.tipoLuna,
    this.montura,
    this.observaciones,
    this.especialista,
    this.vendedorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'dni': dni,
      'telefono': telefono,
      'edad': edad,
      'fechaNacimiento': fechaNacimiento,
      'esDestacado': esDestacado,
      'tienda': tienda,
      'graduacionOd': graduacionOd,
      'avOd': avOd,
      'graduacionOi': graduacionOi,
      'avOi': avOi,
      'adicion': adicion,
      'dip': dip,
      'tipoLuna': tipoLuna,
      'montura': montura,
      'observaciones': observaciones,
      'especialista': especialista,
      'vendedorId': vendedorId,
    };
  }
}
