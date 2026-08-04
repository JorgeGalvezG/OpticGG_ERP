class DashboardResumen {
  // ── MÉTODOS DE PAGO ────────────────────────────────────────────────────────
  final Map<String, double> totalesPorMetodo;

  // ── VENDEDORES ─────────────────────────────────────────────────────────────
  final Map<String, double> ventasPorVendedor;

  // ── ALERTAS ────────────────────────────────────────────────────────────────
  final int cumpleanerosHoy;
  final int ordenesPendientes;

  // ── CONTROL FINANCIERO: HOY ────────────────────────────────────────────────
  final double ingresosHoy;
  final double egresosHoy;

  // ── CONTROL FINANCIERO: ÚLTIMOS 15 DÍAS ───────────────────────────────────
  final double ingresosQuincena;
  final double egresosQuincena;

  // ── CONTROL FINANCIERO: MES ACTUAL ────────────────────────────────────────
  final double ingresosMes;
  final double egresosMes;

  final double? pctIngresosHoy;
  final double? pctEgresosHoy;

  final Map<String, double> ventasVendedores15Dias;
  final Map<String, double> ventasVendedores30Dias;
  final Map<String, double> metodosPagoMes;
  final double metaMensual;

  DashboardResumen({
    required this.totalesPorMetodo,
    required this.ventasPorVendedor,
    required this.cumpleanerosHoy,
    required this.ordenesPendientes,
    required this.ingresosHoy,
    required this.egresosHoy,
    required this.ingresosQuincena,
    required this.egresosQuincena,
    required this.ingresosMes,
    required this.egresosMes,
    this.pctIngresosHoy,
    this.pctEgresosHoy,
    required this.ventasVendedores15Dias,
    required this.ventasVendedores30Dias,
    required this.metodosPagoMes,
    required this.metaMensual,
  });

  factory DashboardResumen.fromJson(Map<String, dynamic> json) {
    // Helper para convertir Map<String, dynamic> a Map<String, double>
    Map<String, double> _toDoubleMap(dynamic raw) {
      if (raw == null) return {};
      final map = raw as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    return DashboardResumen(
      totalesPorMetodo:  _toDoubleMap(json['totalesPorMetodo']),
      ventasPorVendedor: _toDoubleMap(json['ventasPorVendedor']),
      cumpleanerosHoy:   (json['cumpleanerosHoy']  as num?)?.toInt() ?? 0,
      ordenesPendientes: (json['ordenesPendientes'] as num?)?.toInt() ?? 0,
      ingresosHoy:       (json['ingresosHoy']       as num?)?.toDouble() ?? 0.0,
      egresosHoy:        (json['egresosHoy']        as num?)?.toDouble() ?? 0.0,
      ingresosQuincena:  (json['ingresosQuincena']  as num?)?.toDouble() ?? 0.0,
      egresosQuincena:   (json['egresosQuincena']   as num?)?.toDouble() ?? 0.0,
      ingresosMes:       (json['ingresosMes']       as num?)?.toDouble() ?? 0.0,
      egresosMes:        (json['egresosMes']        as num?)?.toDouble() ?? 0.0,
      pctIngresosHoy:    (json['pctIngresosHoy']    as num?)?.toDouble(),
      pctEgresosHoy:     (json['pctEgresosHoy']     as num?)?.toDouble(),
      ventasVendedores15Dias: _toDoubleMap(json['ventasVendedores15Dias']),
      ventasVendedores30Dias: _toDoubleMap(json['ventasVendedores30Dias']),
      metodosPagoMes:         _toDoubleMap(json['metodosPagoMes']),
      metaMensual:            (json['metaMensual'] as num?)?.toDouble() ?? 15000.0,
    );
  }
}