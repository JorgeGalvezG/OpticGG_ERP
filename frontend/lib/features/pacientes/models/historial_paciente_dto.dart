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
  final String? graduacionOi;
  final String? adicion;
  final String? dip;
  final String? tipoLuna;
  final bool? esLunaCliente;
  final String? montura;
  final bool? esMonturaCliente;
  final String? observaciones;
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
    this.graduacionOi,
    this.adicion,
    this.dip,
    this.tipoLuna,
    this.esLunaCliente,
    this.montura,
    this.esMonturaCliente,
    this.observaciones,
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
      graduacionOi: json['graduacionOi'],
      adicion: json['adicion'],
      dip: json['dip'],
      tipoLuna: json['tipoLuna'],
      esLunaCliente: json['esLunaCliente'],
      montura: json['montura'],
      esMonturaCliente: json['esMonturaCliente'],
      observaciones: json['observaciones'],
      fechaConsulta: json['fechaConsulta'],
    );
  }
}