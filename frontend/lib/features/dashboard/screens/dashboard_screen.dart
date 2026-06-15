import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/shared/developer_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pacientes/providers/pacientes_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_resumen.dart';
import '../../ventas/screens/ventas_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _tiendaSeleccionada = 'ALL';
  static const List<String> _tiendas = ['ALL', 'C1', 'C2', 'C3'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final isAdmin = auth.rol?.toUpperCase() == 'ADMIN';
      final tiendaInicial = isAdmin ? 'ALL' : (auth.tienda ?? 'C1');
      setState(() => _tiendaSeleccionada = tiendaInicial);
      
      Provider.of<DashboardProvider>(context, listen: false).fetchResumen(tiendaInicial);
      Provider.of<PacientesProvider>(context, listen: false).fetchPacientes(tiendaInicial);
    });
  }

  void _cambiarTienda(String nuevaTienda) {
    setState(() => _tiendaSeleccionada = nuevaTienda);
    Provider.of<DashboardProvider>(context, listen: false).fetchResumen(nuevaTienda);
    Provider.of<PacientesProvider>(context, listen: false).fetchPacientes(nuevaTienda);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dev = Provider.of<DeveloperProvider>(context);
    final isAdmin = auth.rol?.toUpperCase() == 'ADMIN';
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Consumer<DashboardProvider>(
      builder: (context, dashProv, child) {
        if (dashProv.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (dashProv.errorMessage.isNotEmpty) {
          return _ErrorCard(mensaje: dashProv.errorMessage);
        }

        final resumen = dashProv.resumen;
        if (resumen == null) {
          return const Center(child: Text('No hay datos disponibles.'));
        }

        return Stack(
          children: [
            if (dev.isDevMode)
              Positioned.fill(
                child: Container(decoration: const BoxDecoration(gradient: AppColors.spaceGradient)),
              ),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── CABECERA ───────────────────────────────────────────
                  _HeaderSection(username: auth.username ?? 'Admin', isAdmin: isAdmin, isDev: dev.isDevMode),
                  const SizedBox(height: 40),

                  if (isAdmin) ...[
                    _SelectorTienda(tiendaActual: _tiendaSeleccionada, tiendas: _tiendas, onCambiar: _cambiarTienda, isDev: dev.isDevMode),
                    const SizedBox(height: 40),
                  ],

                  // ── BLOQUE DE MÉTRICAS PRINCIPALES ──────────────────────
                  _SectionTitle('RESUMEN DE OPERACIONES', isDev: dev.isDevMode),
                  const SizedBox(height: 16),
                  _MainStatsGrid(resumen: resumen, isMobile: isMobile, isDev: dev.isDevMode),
                  const SizedBox(height: 48),

                  // ── LAYOUT DE CONTENIDO (MÁS VERTICAL) ─────────────────
                  if (isMobile) 
                    Column(
                      children: [
                        _HistoricalChartHorizontal(resumen: resumen, isDev: dev.isDevMode),
                        const SizedBox(height: 32),
                        _BirthdayBlockCompact(isDev: dev.isDevMode),
                        const SizedBox(height: 32),
                        _QuickActionsBlock(isDev: dev.isDevMode),
                        const SizedBox(height: 32),
                        _GraficoMetodosPago(resumen: resumen, isDev: dev.isDevMode),
                        const SizedBox(height: 32),
                        _RankingVendedores(resumen: resumen, isDev: dev.isDevMode),
                      ],
                    )
                  else 
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna Izquierda: Gráficos y Rankings
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _HistoricalChartHorizontal(resumen: resumen, isDev: dev.isDevMode),
                              const SizedBox(height: 32),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _GraficoMetodosPago(resumen: resumen, isDev: dev.isDevMode),),
                                  const SizedBox(width: 24),
                                  Expanded(child: _RankingVendedores(resumen: resumen, isDev: dev.isDevMode),),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Columna Derecha: Agenda y Acciones
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _BirthdayBlockCompact(isDev: dev.isDevMode),
                              const SizedBox(height: 24),
                              _QuickActionsBlock(isDev: dev.isDevMode),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDev;
  const _SectionTitle(this.title, {this.isDev = false});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDev ? AppColors.starlight.withOpacity(0.5) : AppColors.gray400, letterSpacing: 2));
  }
}

class _HeaderSection extends StatelessWidget {
  final String username;
  final bool isAdmin;
  final bool isDev;
  const _HeaderSection({required this.username, required this.isAdmin, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: isDev ? AppColors.nebulaPink : AppColors.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Text(isDev ? 'SISTEMA DE CONTROL CÓSMICO' : 'CENTRO ÓPTICO CUBAS 20/20 ERP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isDev ? AppColors.nebulaPink : AppColors.primary, letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Hola, $username. Así va el negocio hoy.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDev ? Colors.white : AppColors.gray900)),
      ],
    );
  }
}

class _MainStatsGrid extends StatelessWidget {
  final DashboardResumen resumen;
  final bool isMobile;
  final bool isDev;
  const _MainStatsGrid({required this.resumen, required this.isMobile, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    final balance = resumen.ingresosHoy - resumen.egresosHoy;
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: isMobile ? 1.1 : 1.5,
      children: [
        _StatCard('Ingresos Hoy', resumen.ingresosHoy, Icons.add_circle_outline_rounded, Colors.green, isDev: isDev, pct: resumen.pctIngresosHoy),
        _StatCard('Egresos Hoy', resumen.egresosHoy, Icons.remove_circle_outline_rounded, isDev ? AppColors.nebulaPink : Colors.redAccent, isDev: isDev, pct: resumen.pctEgresosHoy, reversePct: true),
        _StatCard('Balance Neto', balance, Icons.account_balance_wallet_outlined, isDev ? Colors.cyanAccent : Colors.blue, isDev: isDev),
        _StatCard('Pendientes Lab.', resumen.ordenesPendientes.toDouble(), Icons.biotech_rounded, isDev ? AppColors.nebulaPurple : Colors.orange, isMoney: false, isDev: isDev),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final bool isMoney;
  final double? pct;
  final bool reversePct;
  final bool isDev;

  const _StatCard(this.title, this.value, this.icon, this.color, {this.isMoney = true, this.pct, this.reversePct = false, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    bool isPositive = (pct ?? 0) >= 0;
    if (reversePct) isPositive = !isPositive;
    final pctColor = isPositive ? Colors.green : (isDev ? AppColors.nebulaPink : Colors.red);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDev ? 10 : 0, sigmaY: isDev ? 10 : 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDev ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDev ? Colors.white.withOpacity(0.1) : AppColors.gray200),
            boxShadow: isDev ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDev ? Colors.white70 : AppColors.gray500), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                child: Text(isMoney ? 'S/ ${value.toStringAsFixed(2)}' : value.toInt().toString(), 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDev ? Colors.white : AppColors.gray900)),
              ),
              if (pct != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(pct! >= 0 ? Icons.trending_up : Icons.trending_down, size: 12, color: pctColor),
                    const SizedBox(width: 4),
                    Text('${pct! >= 0 ? '+' : ''}${pct!.toStringAsFixed(1)}%', 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: pctColor)),
                    Text(' vs ayer', style: TextStyle(fontSize: 10, color: isDev ? Colors.white38 : AppColors.gray400)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoricalChartHorizontal extends StatelessWidget {
  final DashboardResumen resumen;
  final bool isDev;
  const _HistoricalChartHorizontal({required this.resumen, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDev ? Colors.white.withOpacity(0.05) : Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: isDev ? Colors.white.withOpacity(0.1) : AppColors.gray200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle('FLUJO DE CAJA (COMPARATIVO)', isDev: isDev),
              Row(
                children: [
                  _indicator('Ingresos', Colors.green.shade400),
                  const SizedBox(width: 16),
                  _indicator('Egresos', isDev ? AppColors.nebulaPink : Colors.red.shade400),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        TextStyle style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDev ? Colors.white70 : AppColors.gray700);
                        if (v == 0) return Text('Hoy', style: style);
                        if (v == 1) return Text('15 Días', style: style);
                        if (v == 2) return Text('30 Días', style: style);
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (v, m) => Text('S/ ${v.toInt()}', style: TextStyle(fontSize: 9, color: isDev ? Colors.white38 : AppColors.gray400)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: isDev ? Colors.white10 : AppColors.gray100, strokeWidth: 1)),
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  _group(0, resumen.ingresosHoy, resumen.egresosHoy),
                  _group(1, resumen.ingresosQuincena, resumen.egresosQuincena),
                  _group(2, resumen.ingresosMes, resumen.egresosMes),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicator(String l, Color c) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 4), Text(l, style: TextStyle(fontSize: 10, color: isDev ? Colors.white54 : AppColors.gray500))]);

  BarChartGroupData _group(int x, double ing, double egr) {
    return BarChartGroupData(
      x: x, 
      barRods: [
        BarChartRodData(toY: ing, color: Colors.green.shade400, width: 15, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: egr, color: isDev ? AppColors.nebulaPink : Colors.red.shade400, width: 15, borderRadius: BorderRadius.circular(4)),
      ],
      barsSpace: 4,
    );
  }
}

class _BirthdayBlockCompact extends StatelessWidget {
  final bool isDev;
  const _BirthdayBlockCompact({this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<PacientesProvider>(
      builder: (context, prov, _) {
        final hoyStr = "${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
        final cumplenHoy = prov.pacientes.where((p) => p.fechaNacimiento?.substring(5) == hoyStr).toList();

        final bg = isDev ? AppColors.nebulaPurple.withOpacity(0.1) : const Color(0xFFF0F9FF);
        final border = isDev ? AppColors.nebulaPurple.withOpacity(0.3) : const Color(0xFFBAE6FD);
        final textCol = isDev ? Colors.white : const Color(0xFF0369A1);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24), border: Border.all(color: border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cake_rounded, color: textCol, size: 20),
                  const SizedBox(width: 10),
                  Text('CUMPLEAÑOS DE HOY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: textCol, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 20),
              if (cumplenHoy.isNotEmpty)
                ...cumplenHoy.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: isDev ? AppColors.nebulaPink : const Color(0xFF0EA5E9), shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Text('${p.nombre} ${p.apellidos}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDev ? Colors.white : AppColors.gray800)),
                    ],
                  ),
                ))
              else
                Text('No hay cumpleaños registrados hoy.', style: TextStyle(fontSize: 12, color: isDev ? Colors.white38 : AppColors.gray500, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionsBlock extends StatelessWidget {
  final bool isDev;
  const _QuickActionsBlock({this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDev ? Colors.white.withOpacity(0.05) : Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: isDev ? Colors.white.withOpacity(0.1) : AppColors.gray200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('ACCESOS DIRECTOS', isDev: isDev),
          const SizedBox(height: 24),
          _actionButton(context, Icons.add_shopping_cart_rounded, 'Nueva Venta', isDev ? AppColors.starlight : Colors.blue, () {
             showDialog(context: context, barrierDismissible: false, builder: (context) => const NuevaVentaDialog());
          }),
          _actionButton(context, Icons.person_add_alt_1_rounded, 'Ir a Pacientes', isDev ? AppColors.nebulaPink : Colors.green, () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use el menú lateral para ir a Pacientes.')));
          }),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.1))),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDev ? Colors.white : AppColors.gray800)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GraficoMetodosPago extends StatelessWidget {
  final DashboardResumen resumen;
  final bool isDev;
  const _GraficoMetodosPago({required this.resumen, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    final datos = resumen.metodosPagoMes;
    final total = datos.values.fold(0.0, (a, b) => a + b);
    final colores = [
      isDev ? AppColors.starlight : Colors.green.shade400,
      isDev ? AppColors.nebulaPurple : Colors.blue.shade400,
      isDev ? AppColors.nebulaPink : Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.cyan.shade400,
      Colors.pink.shade400,
    ];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDev ? Colors.white.withOpacity(0.05) : Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: isDev ? Colors.white.withOpacity(0.1) : AppColors.gray200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('MÉTODOS DE PAGO (MENSUAL)', isDev: isDev),
          const SizedBox(height: 24),
          if (total == 0)
            SizedBox(height: 180, child: Center(child: Text('Sin datos este mes', style: TextStyle(fontSize: 12, color: isDev ? Colors.white38 : AppColors.gray400))))
          else ...[
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 35,
                  sections: datos.entries.toList().asMap().entries.map((entry) {
                    final idx = entry.key;
                    final val = entry.value.value;
                    final pct = (val / total * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      value: val,
                      title: '$pct%',
                      radius: 40,
                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      color: idx < colores.length ? colores[idx] : Colors.grey,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: datos.entries.toList().asMap().entries.map((entry) {
                final idx = entry.key;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: idx < colores.length ? colores[idx] : Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(entry.value.key, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDev ? Colors.white70 : AppColors.gray800)),
                  ],
                );
              }).toList(),
            )
          ],
        ],
      ),
    );
  }
}

class _RankingVendedores extends StatefulWidget {
  final DashboardResumen resumen;
  final bool isDev;
  const _RankingVendedores({required this.resumen, this.isDev = false});

  @override
  State<_RankingVendedores> createState() => _RankingVendedoresState();
}

class _RankingVendedoresState extends State<_RankingVendedores> {
  int _timeframe = 0; // 0: Hoy, 1: 15 Dias, 2: 30 Dias

  @override
  Widget build(BuildContext context) {
    Map<String, double> datos;
    String label;
    if (_timeframe == 0) {
      datos = widget.resumen.ventasPorVendedor;
      label = 'VENTAS HOY';
    } else if (_timeframe == 1) {
      datos = widget.resumen.ventasVendedores15Dias;
      label = 'VENTAS 15 DÍAS';
    } else {
      datos = widget.resumen.ventasVendedores30Dias;
      label = 'VENTAS 30 DÍAS';
    }

    final sorted = datos.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1.0 : sorted.first.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDev ? Colors.white.withOpacity(0.05) : Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: widget.isDev ? Colors.white.withOpacity(0.1) : AppColors.gray200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(label, isDev: widget.isDev),
              DropdownButton<int>(
                value: _timeframe,
                underline: const SizedBox(),
                dropdownColor: widget.isDev ? AppColors.cosmicDeep : Colors.white,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.isDev ? AppColors.starlight : AppColors.primary),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Hoy')),
                  DropdownMenuItem(value: 1, child: Text('15 Días')),
                  DropdownMenuItem(value: 2, child: Text('30 Días')),
                ],
                onChanged: (v) => setState(() => _timeframe = v!),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (sorted.isEmpty)
             SizedBox(height: 100, child: Center(child: Text('Sin ventas en este periodo', style: TextStyle(fontSize: 12, color: widget.isDev ? Colors.white38 : AppColors.gray400))))
          else
            ...sorted.take(5).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: widget.isDev ? Colors.white : AppColors.gray800)),
                      Text('S/ ${e.value.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: widget.isDev ? AppColors.nebulaPink : AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: e.value / maxVal, backgroundColor: widget.isDev ? Colors.white10 : AppColors.gray100, color: widget.isDev ? AppColors.starlight : AppColors.primary.withOpacity(0.6), minHeight: 4),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }
}

class _SelectorTienda extends StatelessWidget {
  final String tiendaActual;
  final List<String> tiendas;
  final ValueChanged<String> onCambiar;
  final bool isDev;
  const _SelectorTienda({required this.tiendaActual, required this.tiendas, required this.onCambiar, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tiendas.map((t) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(t == 'ALL' ? 'GENERAL' : 'TIENDA $t', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            selected: tiendaActual == t,
            onSelected: (val) => onCambiar(t),
            selectedColor: isDev ? AppColors.nebulaPurple : AppColors.primary,
            backgroundColor: isDev ? Colors.white.withOpacity(0.05) : Colors.white,
            side: BorderSide(color: tiendaActual == t ? (isDev ? AppColors.nebulaPurple : AppColors.primary) : (isDev ? Colors.white10 : AppColors.gray200)),
            labelStyle: TextStyle(color: tiendaActual == t ? Colors.white : (isDev ? Colors.white38 : AppColors.gray500)),
          ),
        )).toList(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String mensaje;
  const _ErrorCard({required this.mensaje});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $mensaje', style: const TextStyle(color: Colors.red)));
  }
}
