class HistorialPacienteDTO {
  final int? pacienteId;
  final String? nombreCompleto;

  // Última venta
  final int? ventaId;
  final String? fechaVenta;
  final double? montoTotal;
  final double? montoSaldo;
  final String? estadoPago;
  final String? metodoPago;

  // Última medida
  final String? graduacionOd;
  final String? avOd;
  final String? graduacionOi;
  final String? avOi;
  final String? adicion;
  final String? dip;
  final String? tipoLuna;
  final bool? esLunaCliente;
  final String? montura;
  final bool? esMonturaCliente;
  final String? observaciones;
  final String? especialista;
  final String? fechaConsulta;

  HistorialPacienteDTO({
    this.pacienteId,
    this.nombreCompleto,
    this.ventaId,
    this.fechaVenta,
    this.montoTotal,
    this.montoSaldo,
    this.estadoPago,
    this.metodoPago,
    this.graduacionOd,
    this.avOd,
    this.graduacionOi,
    this.avOi,
    this.adicion,
    this.dip,
    this.tipoLuna,
    this.esLunaCliente,
    this.montura,
    this.esMonturaCliente,
    this.observaciones,
    this.especialista,
    this.fechaConsulta,
  });

  factory HistorialPacienteDTO.fromJson(Map<String, dynamic> json) {
    return HistorialPacienteDTO(
      pacienteId: json['pacienteId'],
      nombreCompleto: json['nombreCompleto'],
      ventaId: json['ventaId'],
      fechaVenta: json['fechaVenta'],
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      montoSaldo: (json['montoSaldo'] ?? 0).toDouble(),
      estadoPago: json['estadoPago'],
      metodoPago: json['metodoPago'],
      graduacionOd: json['graduacionOd'],
      avOd: json['avOd'],
      graduacionOi: json['graduacionOi'],
      avOi: json['avOi'],
      adicion: json['adicion'],
      dip: json['dip'],
      tipoLuna: json['tipoLuna'],
      esLunaCliente: json['esLunaCliente'],
      montura: json['montura'],
      esMonturaCliente: json['esMonturaCliente'],
      observaciones: json['observaciones'],
      especialista: json['especialista'],
      fechaConsulta: json['fechaConsulta'],
    );
  }
}
