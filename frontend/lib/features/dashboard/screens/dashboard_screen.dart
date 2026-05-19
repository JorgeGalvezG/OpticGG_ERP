import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

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
      // El admin inicia viendo todo; el vendedor ve solo su tienda
      final tiendaInicial = isAdmin ? 'ALL' : (auth.tienda ?? 'C1');
      setState(() => _tiendaSeleccionada = tiendaInicial);
      Provider.of<DashboardProvider>(context, listen: false)
          .fetchResumen(tiendaInicial);
    });
  }

  void _cambiarTienda(String nuevaTienda) {
    setState(() => _tiendaSeleccionada = nuevaTienda);
    Provider.of<DashboardProvider>(context, listen: false)
        .fetchResumen(nuevaTienda);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.rol?.toUpperCase() == 'ADMIN';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Consumer<DashboardProvider>(
      builder: (context, dashProv, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ─────────────────────────────────────────
              // 1. BANNER DE BIENVENIDA
              // ─────────────────────────────────────────
              _BannerBienvenida(
                username: auth.username ?? 'Usuario',
                tienda: isAdmin ? 'Administración General' : 'ADMINISTRADOR',
                isMobile: isMobile,
              ),
              const SizedBox(height: 20),

              // ─────────────────────────────────────────
              // 2. SELECTOR DE TIENDA (solo ADMIN)
              // ─────────────────────────────────────────
              if (isAdmin) ...[
                _SelectorTienda(
                  tiendaActual: _tiendaSeleccionada,
                  tiendas: _tiendas,
                  onCambiar: _cambiarTienda,
                ),
                const SizedBox(height: 20),
              ],

              // ─────────────────────────────────────────
              // 3. ESTADO: CARGANDO
              // ─────────────────────────────────────────
              if (dashProv.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (dashProv.errorMessage.isNotEmpty)
                _ErrorCard(mensaje: dashProv.errorMessage)
              else if (dashProv.resumen == null)
                  const Center(child: Text('Sin datos disponibles.'))
                else
                  _DashboardContenido(
                    resumen: dashProv.resumen!,
                    isMobile: isMobile,
                  ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// CONTENIDO PRINCIPAL (extraído para evitar final en spread)
// ─────────────────────────────────────────────────────────
class _DashboardContenido extends StatelessWidget {
  final dynamic resumen; // DashboardResumen
  final bool isMobile;

  static const Map<String, Color> _coloresPago = {
    'EFECTIVO': Color(0xFF16a34a),
    'YAPE / PLIN': Color(0xFF7c3aed),
    'TARJETA': Color(0xFF2563eb),
    'TRANSF.': Color(0xFFea580c),
  };

  static const Map<String, String> _etiquetasPago = {
    'EFECTIVO': 'Efectivo',
    'YAPE / PLIN': 'Yape / Plin',
    'TARJETA': 'Tarjeta',
    'TRANSF.': 'Transferencia',
  };

  const _DashboardContenido({required this.resumen, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─────────────────────────────────────────
        // 4. ALERTAS: CUMPLEAÑOS Y LABORATORIO
        // ─────────────────────────────────────────
        if (resumen.cumpleanerosHoy > 0) ...[
          _AlertaBanner(
            icono: Icons.cake_rounded,
            color: const Color(0xFFdb2777),
            colorFondo: const Color(0xFFFDF2F8),
            colorBorde: const Color(0xFFfbcfe8),
            mensaje:
            '¡Hoy hay ${resumen.cumpleanerosHoy} paciente${resumen.cumpleanerosHoy > 1 ? 's' : ''} de cumpleaños! 🎂 Considera llamarles.',
          ),
          const SizedBox(height: 12),
        ],
        if (resumen.ordenesPendientes > 0) ...[
          _AlertaBanner(
            icono: Icons.science_rounded,
            color: const Color(0xFF2563eb),
            colorFondo: const Color(0xFFEFF6FF),
            colorBorde: const Color(0xFFbfdbfe),
            mensaje:
            '${resumen.ordenesPendientes} orden${resumen.ordenesPendientes > 1 ? 'es' : ''} pendiente${resumen.ordenesPendientes > 1 ? 's' : ''} en el laboratorio.',
          ),
          const SizedBox(height: 20),
        ],
        if (resumen.cumpleanerosHoy == 0 && resumen.ordenesPendientes == 0)
          const SizedBox(height: 4),

        // ─────────────────────────────────────────
        // 5. DISTRIBUCIÓN POR MÉTODO DE PAGO
        // ─────────────────────────────────────────
        const Text(
          'Ingresos de hoy por método de pago',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900),
        ),
        const SizedBox(height: 14),
        _GraficoMetodosPago(
          datos: resumen.totalesPorMetodo,
          colores: _coloresPago,
          etiquetas: _etiquetasPago,
          isMobile: isMobile,
        ),
        const SizedBox(height: 28),

        // ─────────────────────────────────────────
        // 6. RANKING DE VENDEDORES
        // ─────────────────────────────────────────
        const Text(
          'Top vendedores — ventas del día',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900),
        ),
        const SizedBox(height: 14),
        _RankingVendedores(
          vendedores: resumen.ventasPorVendedor,
          isMobile: isMobile,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// WIDGETS PRIVADOS
// ═══════════════════════════════════════════════════════════

// ── BANNER DE BIENVENIDA ──────────────────────────────────
class _BannerBienvenida extends StatelessWidget {
  final String username;
  final String tienda;
  final bool isMobile;

  const _BannerBienvenida({
    required this.username,
    required this.tienda,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.loginGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $username! 👋',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rendimiento · $tienda',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights_rounded,
                  color: Colors.white, size: 44),
            ),
        ],
      ),
    );
  }
}

// ── SELECTOR DE TIENDA (solo ADMIN) ──────────────────────
class _SelectorTienda extends StatelessWidget {
  final String tiendaActual;
  final List<String> tiendas;
  final ValueChanged<String> onCambiar;

  const _SelectorTienda({
    required this.tiendaActual,
    required this.tiendas,
    required this.onCambiar,
  });

  String _etiqueta(String t) {
    if (t == 'ALL') return '🌐 Todas las tiendas';
    return '🏪 Sucursal $t';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: tiendas.map((t) {
          final isActive = t == tiendaActual;
          return Expanded(
            child: GestureDetector(
              onTap: () => onCambiar(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                    const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _etiqueta(t),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                      isActive ? AppColors.primary : AppColors.gray500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── BANNER DE ALERTA ─────────────────────────────────────
class _AlertaBanner extends StatelessWidget {
  final IconData icono;
  final Color color;
  final Color colorFondo;
  final Color colorBorde;
  final String mensaje;

  const _AlertaBanner({
    required this.icono,
    required this.color,
    required this.colorFondo,
    required this.colorBorde,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorBorde),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── GRÁFICO DE MÉTODOS DE PAGO ───────────────────────────
class _GraficoMetodosPago extends StatefulWidget {
  final Map<String, double> datos;
  final Map<String, Color> colores;
  final Map<String, String> etiquetas;
  final bool isMobile;

  const _GraficoMetodosPago({
    required this.datos,
    required this.colores,
    required this.etiquetas,
    required this.isMobile,
  });

  @override
  State<_GraficoMetodosPago> createState() => _GraficoMetodosPagoState();
}

class _GraficoMetodosPagoState extends State<_GraficoMetodosPago> {
  int _indexTocado = -1;

  Color _colorMetodo(String metodo) {
    return widget.colores[metodo] ?? AppColors.gray400;
  }

  String _etiquetaMetodo(String metodo) {
    return widget.etiquetas[metodo] ?? metodo;
  }

  @override
  Widget build(BuildContext context) {
    final datos = widget.datos;
    final total = datos.values.fold(0.0, (a, b) => a + b);

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.gray300),
              SizedBox(height: 10),
              Text('Sin ingresos registrados hoy',
                  style: TextStyle(color: AppColors.gray500, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final secciones = datos.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = secciones.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final isTocado = i == _indexTocado;
      return PieChartSectionData(
        value: e.value,
        color: _colorMetodo(e.key),
        radius: isTocado ? 68 : 56,
        title: isTocado
            ? 'S/ ${e.value.toStringAsFixed(0)}'
            : '${(e.value / total * 100).toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white),
        badgeWidget: null,
      );
    }).toList();

    final grafico = SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 3,
          centerSpaceRadius: 44,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.touchedSection == null) {
                  _indexTocado = -1;
                  return;
                }
                _indexTocado =
                    response.touchedSection!.touchedSectionIndex;
              });
            },
          ),
        ),
      ),
    );

    // Leyenda con tarjetas por cada método
    final leyenda = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: secciones.map((e) {
        final porcentaje = (e.value / total * 100).toStringAsFixed(1);
        final color = _colorMetodo(e.key);
        return Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border:
            Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _etiquetaMetodo(e.key),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                  Text(
                    'S/ ${e.value.toStringAsFixed(2)} · $porcentaje%',
                    style: TextStyle(
                        fontSize: 11,
                        color: color.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );

    // Centro del donut muestra total
    final centroWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Total',
            style: TextStyle(fontSize: 11, color: AppColors.gray500)),
        Text(
          'S/ ${total.toStringAsFixed(0)}',
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: widget.isMobile
          ? Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [grafico, centroWidget],
          ),
          const SizedBox(height: 20),
          leyenda,
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [grafico, centroWidget],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(flex: 3, child: leyenda),
        ],
      ),
    );
  }
}

// ── RANKING DE VENDEDORES ────────────────────────────────
class _RankingVendedores extends StatelessWidget {
  final Map<String, double> vendedores;
  final bool isMobile;

  const _RankingVendedores({
    required this.vendedores,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (vendedores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
        ),
        child: const Center(
          child: Text('Sin ventas registradas hoy',
              style: TextStyle(color: AppColors.gray500, fontSize: 14)),
        ),
      );
    }

    // Ordenar de mayor a menor
    final sorted = vendedores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxVenta = sorted.first.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final porcentaje = maxVenta > 0 ? e.value / maxVenta : 0.0;

          String? medallaTexto;
          Color colorMedalla = AppColors.primary;

          if (index == 0) {
            medallaTexto = '🥇';
            colorMedalla = const Color(0xFFD97706);
          } else if (index == 1) {
            medallaTexto = '🥈';
            colorMedalla = const Color(0xFF6B7280);
          } else if (index == 2) {
            medallaTexto = '🥉';
            colorMedalla = const Color(0xFFB45309);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Posición / medalla
                    SizedBox(
                      width: 36,
                      child: medallaTexto != null
                          ? Text(medallaTexto,
                          style: const TextStyle(fontSize: 20))
                          : CircleAvatar(
                        radius: 14,
                        backgroundColor:
                        AppColors.primaryLight,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.gray900),
                              ),
                              Text(
                                'S/ ${e.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colorMedalla),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Barra de progreso relativa
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: porcentaje,
                              minHeight: 6,
                              backgroundColor: AppColors.gray100,
                              valueColor:
                              AlwaysStoppedAnimation(colorMedalla),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index < sorted.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Divider(height: 1, color: AppColors.gray100),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── TARJETA DE ERROR ─────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String mensaje;
  const _ErrorCard({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFfecaca)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFdc2626), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error al cargar datos: $mensaje',
              style: const TextStyle(
                  color: Color(0xFFdc2626),
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}