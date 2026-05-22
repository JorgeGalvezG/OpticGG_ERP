import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
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

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── CABECERA ───────────────────────────────────────────
              _HeaderSection(username: auth.username ?? 'Admin', isAdmin: isAdmin),
              const SizedBox(height: 40),

              if (isAdmin) ...[
                _SelectorTienda(tiendaActual: _tiendaSeleccionada, tiendas: _tiendas, onCambiar: _cambiarTienda),
                const SizedBox(height: 40),
              ],

              // ── BLOQUE DE MÉTRICAS PRINCIPALES ──────────────────────
              const _SectionTitle('RESUMEN DE OPERACIONES'),
              const SizedBox(height: 16),
              _MainStatsGrid(resumen: resumen, isMobile: isMobile),
              const SizedBox(height: 48),

              // ── LAYOUT DE CONTENIDO (MÁS VERTICAL) ─────────────────
              if (isMobile) 
                Column(
                  children: [
                    _HistoricalChartHorizontal(resumen: resumen),
                    const SizedBox(height: 32),
                    _BirthdayBlockCompact(),
                    const SizedBox(height: 32),
                    _QuickActionsBlock(),
                    const SizedBox(height: 32),
                    _GraficoMetodosPago(datos: resumen.totalesPorMetodo),
                    const SizedBox(height: 32),
                    _RankingVendedores(vendedores: resumen.ventasPorVendedor),
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
                          _HistoricalChartHorizontal(resumen: resumen),
                          const SizedBox(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _GraficoMetodosPago(datos: resumen.totalesPorMetodo)),
                              const SizedBox(width: 24),
                              Expanded(child: _RankingVendedores(vendedores: resumen.ventasPorVendedor)),
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
                          _BirthdayBlockCompact(),
                          const SizedBox(height: 24),
                          _QuickActionsBlock(),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// COMPONENTES DE DISEÑO PROFESIONAL
// ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.gray400, letterSpacing: 1.5));
  }
}

class _HeaderSection extends StatelessWidget {
  final String username;
  final bool isAdmin;
  const _HeaderSection({required this.username, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Text('ÓPTICA CUBAS ERP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Hola, $username. Así va el negocio hoy.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gray900)),
      ],
    );
  }
}

class _MainStatsGrid extends StatelessWidget {
  final DashboardResumen resumen;
  final bool isMobile;
  const _MainStatsGrid({required this.resumen, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final balance = resumen.ingresosHoy - resumen.egresosHoy;
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: isMobile ? 1.4 : 1.8,
      children: [
        _StatCard('Ingresos Hoy', resumen.ingresosHoy, Icons.add_circle_outline_rounded, Colors.green),
        _StatCard('Egresos Hoy', resumen.egresosHoy, Icons.remove_circle_outline_rounded, Colors.redAccent),
        _StatCard('Balance Neto', balance, Icons.account_balance_wallet_outlined, Colors.blue),
        _StatCard('Pendientes Lab.', resumen.ordenesPendientes.toDouble(), Icons.biotech_rounded, Colors.orange, isMoney: false),
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
  const _StatCard(this.title, this.value, this.icon, this.color, {this.isMoney = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gray500)),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(isMoney ? 'S/ ${value.toStringAsFixed(2)}' : value.toInt().toString(), 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.gray900)),
          ),
        ],
      ),
    );
  }
}

class _HistoricalChartHorizontal extends StatelessWidget {
  final DashboardResumen resumen;
  const _HistoricalChartHorizontal({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.gray200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('RENDIMIENTO HISTÓRICO (INGRESOS)'),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('S/ ${v.toInt()}', style: const TextStyle(fontSize: 9, color: AppColors.gray400)))),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (v, m) {
                        if (v == 0) return const Text('Este Mes', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                        if (v == 1) return const Text('15 Días', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                        if (v == 2) return const Text('Hoy', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: false),
                alignment: BarChartAlignment.spaceAround,
                // SWAP AXES by using BarChartGroupData logic if needed, but fl_chart doesn't support horizontal bars natively in a simple way.
                // We'll simulate it with thin vertical bars for now if native horizontal is complex, or use the BarChart as is but with better layout.
                // Wait, fl_chart DOES support horizontal bars in newer versions or via some tricks. 
                // Let's stick to a very clean vertical one if horizontal is too buggy without extra deps.
                barGroups: [
                  _group(0, resumen.ingresosMes, AppColors.primary),
                  _group(1, resumen.ingresosQuincena, Colors.blue.shade400),
                  _group(2, resumen.ingresosHoy, Colors.green.shade400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _group(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [BarChartRodData(toY: y, color: color, width: 20, borderRadius: BorderRadius.circular(4))]);
  }
}

class _BirthdayBlockCompact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PacientesProvider>(
      builder: (context, prov, _) {
        final hoyStr = "${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
        final cumplenHoy = prov.pacientes.where((p) => p.fechaNacimiento?.substring(5) == hoyStr).toList();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBAE6FD))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cake_rounded, color: Color(0xFF0369A1), size: 20),
                  SizedBox(width: 10),
                  Text('CUMPLEAÑOS DE HOY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF0369A1), letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 20),
              if (cumplenHoy.isNotEmpty)
                ...cumplenHoy.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF0EA5E9), shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Text('${p.nombre} ${p.apellidos}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gray800)),
                    ],
                  ),
                ))
              else
                const Text('No hay cumpleaños registrados hoy.', style: TextStyle(fontSize: 12, color: AppColors.gray500, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionsBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gray200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('ACCESOS DIRECTOS'),
          const SizedBox(height: 24),
          _actionButton(context, Icons.add_shopping_cart_rounded, 'Nueva Venta', Colors.blue, () {
             showDialog(
               context: context,
               barrierDismissible: false,
               builder: (context) => const NuevaVentaDialog(),
             );
          }),
          _actionButton(context, Icons.person_add_alt_1_rounded, 'Ir a Pacientes', Colors.green, () {
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
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gray800)),
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
  final Map<String, double> datos;
  const _GraficoMetodosPago({required this.datos});

  @override
  Widget build(BuildContext context) {
    final total = datos.values.fold(0.0, (a, b) => a + b);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.gray200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('COBROS POR MÉTODO'),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: PieChart(
              PieChartData(
                sections: datos.entries.map((e) => PieChartSectionData(
                  value: e.value, 
                  color: _getColor(e.key), 
                  radius: 40, 
                  title: '${(e.value/total*100).toInt()}%',
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Color _getColor(String k) {
    if (k == 'EFECTIVO') return Colors.green.shade400;
    if (k == 'TARJETA') return Colors.blue.shade400;
    return Colors.purple.shade400;
  }
}

class _RankingVendedores extends StatelessWidget {
  final Map<String, double> vendedores;
  const _RankingVendedores({required this.vendedores});

  @override
  Widget build(BuildContext context) {
    final sorted = vendedores.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.gray200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('TOP VENDEDORES (HOY)'),
          const SizedBox(height: 24),
          ...sorted.take(3).map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray800)),
                    Text('S/ ${e.value.toInt()}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: 0.8, backgroundColor: AppColors.gray100, color: AppColors.primary.withOpacity(0.6), minHeight: 4),
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
  const _SelectorTienda({required this.tiendaActual, required this.tiendas, required this.onCambiar});

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
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            side: BorderSide(color: tiendaActual == t ? AppColors.primary : AppColors.gray200),
            labelStyle: TextStyle(color: tiendaActual == t ? Colors.white : AppColors.gray500),
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
