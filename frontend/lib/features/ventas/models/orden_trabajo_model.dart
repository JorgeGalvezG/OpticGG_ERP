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
  final String? tipoLunaOd;
  final double? precioLunaOd;
  final String? tipoLunaOi;
  final double? precioLunaOi;
  final bool? esLunaCliente;
  
  final String? montura;
  final double? precioMontura;
  final bool? esMonturaCliente;

  final String? graduacionOd;
  final String? avOd;
  final String? graduacionOi;
  final String? avOi;
  final String? adicion;
  final String? dip;
  final String? observaciones;

  // Compra Extra fields
  final bool? tieneCompraExtra;
  final String? graduacionOdExtra;
  final String? avOdExtra;
  final String? graduacionOiExtra;
  final String? avOiExtra;
  final String? adicionExtra;
  final String? dipExtra;
  final String? tipoLunaExtra;
  final String? tipoLunaOdExtra;
  final double? precioLunaOdExtra;
  final String? tipoLunaOiExtra;
  final double? precioLunaOiExtra;
  final bool? esLunaClienteExtra;
  final String? monturaExtra;
  final double? precioMonturaExtra;
  final bool? esMonturaClienteExtra;
  final String? observacionesExtra;
  final String? especialistaExtra;

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
    this.tipoLunaOd,
    this.precioLunaOd,
    this.tipoLunaOi,
    this.precioLunaOi,
    this.esLunaCliente,
    this.montura,
    this.precioMontura,
    this.esMonturaCliente,
    this.graduacionOd,
    this.avOd,
    this.graduacionOi,
    this.avOi,
    this.adicion,
    this.dip,
    this.observaciones,
    this.tieneCompraExtra,
    this.graduacionOdExtra,
    this.avOdExtra,
    this.graduacionOiExtra,
    this.avOiExtra,
    this.adicionExtra,
    this.dipExtra,
    this.tipoLunaExtra,
    this.tipoLunaOdExtra,
    this.precioLunaOdExtra,
    this.tipoLunaOiExtra,
    this.precioLunaOiExtra,
    this.esLunaClienteExtra,
    this.monturaExtra,
    this.precioMonturaExtra,
    this.esMonturaClienteExtra,
    this.observacionesExtra,
    this.especialistaExtra,
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
      tipoLunaOd: json['tipoLunaOd'],
      precioLunaOd: (json['precioLunaOd'] ?? 0).toDouble(),
      tipoLunaOi: json['tipoLunaOi'],
      precioLunaOi: (json['precioLunaOi'] ?? 0).toDouble(),
      esLunaCliente: json['esLunaCliente'],
      montura: json['montura'],
      precioMontura: (json['precioMontura'] ?? 0).toDouble(),
      esMonturaCliente: json['esMonturaCliente'],
      graduacionOd: json['graduacionOd'],
      avOd: json['avOd'],
      graduacionOi: json['graduacionOi'],
      avOi: json['avOi'],
      adicion: json['adicion'],
      dip: json['dip'],
      observaciones: json['observaciones'],
      tieneCompraExtra: json['tieneCompraExtra'],
      graduacionOdExtra: json['graduacionOdExtra'],
      avOdExtra: json['avOdExtra'],
      graduacionOiExtra: json['graduacionOiExtra'],
      avOiExtra: json['avOiExtra'],
      adicionExtra: json['adicionExtra'],
      dipExtra: json['dipExtra'],
      tipoLunaExtra: json['tipoLunaExtra'],
      tipoLunaOdExtra: json['tipoLunaOdExtra'],
      precioLunaOdExtra: (json['precioLunaOdExtra'] ?? 0).toDouble(),
      tipoLunaOiExtra: json['tipoLunaOiExtra'],
      precioLunaOiExtra: (json['precioLunaOiExtra'] ?? 0).toDouble(),
      esLunaClienteExtra: json['esLunaClienteExtra'],
      monturaExtra: json['monturaExtra'],
      precioMonturaExtra: (json['precioMonturaExtra'] ?? 0).toDouble(),
      esMonturaClienteExtra: json['esMonturaClienteExtra'],
      observacionesExtra: json['observacionesExtra'],
      especialistaExtra: json['especialistaExtra'],
    );
  }
}
