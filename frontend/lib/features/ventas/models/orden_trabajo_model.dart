class OrdenTrabajo {
  final int id;
  final String numeroOrden;
  final String pacienteNombre;
  final String? pacienteTelefono;
  final String estado;
  final double montoTotal;
  final double montoSaldo;
  final String fecha;

  // Campos del historial clínico (para el ticket PDF)
  final String? tipoLuna;
  final bool? esLunaCliente;
  final String? montura;
  final bool? esMonturaCliente;
  final String? graduacionOd;
  final String? graduacionOi;
  final String? adicion;
  final String? dip;
  final String? observaciones;

  OrdenTrabajo({
    required this.id,
    required this.numeroOrden,
    required this.pacienteNombre,
    this.pacienteTelefono,
    required this.estado,
    required this.montoTotal,
    required this.montoSaldo,
    required this.fecha,
    this.tipoLuna,
    this.esLunaCliente,
    this.montura,
    this.esMonturaCliente,
    this.graduacionOd,
    this.graduacionOi,
    this.adicion,
    this.dip,
    this.observaciones,
  });

  factory OrdenTrabajo.fromJson(Map<String, dynamic> json) {
    // Extraemos el nombre del paciente del objeto anidado "cliente" que manda Java
    final cliente = json['cliente'] ?? {};
    final nombreCompleto = "${cliente['nombre'] ?? ''} ${cliente['apellidos'] ?? ''}".trim();
    final telefono = cliente['telefono'];

    return OrdenTrabajo(
      id: json['id'] ?? 0,
      numeroOrden: json['numeroOrden'] ?? 'Sin Orden',
      pacienteNombre: nombreCompleto.isEmpty ? 'Cliente Desconocido' : nombreCompleto,
      pacienteTelefono: telefono,
      estado: json['estado'] ?? 'PENDIENTE',
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      montoSaldo: (json['montoSaldo'] ?? 0).toDouble(),
      fecha: json['fecha'] ?? '',
      tipoLuna: json['tipoLuna'],
      esLunaCliente: json['esLunaCliente'],
      montura: json['montura'],
      esMonturaCliente: json['esMonturaCliente'],
      graduacionOd: json['graduacionOd'],
      graduacionOi: json['graduacionOi'],
      adicion: json['adicion'],
      dip: json['dip'],
      observaciones: json['observaciones'],
    );
  }
}