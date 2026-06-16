import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/shared/developer_provider.dart';
import '../providers/reportes_provider.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  int _vistaActual = 0; // 0: Mensual, 1: Diario
  String _tiendaFiltro = 'ALL';
  String _filtroBuscador = '';
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportesProvider>(context, listen: false).fetchReportesGlobales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dev = Provider.of<DeveloperProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Stack(
      children: [
        if (dev.isDevMode) Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.spaceGradient))),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Historial General', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: dev.isDevMode ? Colors.white : AppColors.gray900)),
                        Text('Análisis comparativo de la empresa', style: TextStyle(fontSize: 14, color: dev.isDevMode ? Colors.white38 : AppColors.gray500)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Provider.of<ReportesProvider>(context, listen: false).fetchReportesGlobales(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Actualizar'),
                      style: ElevatedButton.styleFrom(backgroundColor: dev.isDevMode ? AppColors.nebulaPurple : AppColors.primary, foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Filtros y Buscador
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildToggle('Mensual', 0, dev.isDevMode),
                    _buildToggle('Diario', 1, dev.isDevMode),
                    const SizedBox(width: 8),
                    _buildTiendaChip('ALL', dev.isDevMode),
                    _buildTiendaChip('C1', dev.isDevMode),
                    _buildTiendaChip('C2', dev.isDevMode),
                    _buildTiendaChip('C3', dev.isDevMode),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: isMobile ? double.infinity : 300,
                      child: TextField(
                        onChanged: (v) => setState(() => _filtroBuscador = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Filtrar por fecha o mes...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
                        if (picked != null) setState(() => _rangoFechas = picked);
                      },
                      icon: const Icon(Icons.date_range_rounded),
                      label: Text(_rangoFechas == null ? 'Filtrar Rango' : 'Filtrado'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    if (_rangoFechas != null)
                      IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setState(() => _rangoFechas = null)),
                  ],
                ),
                const SizedBox(height: 24),

                Consumer<ReportesProvider>(
                  builder: (context, prov, _) {
                    if (prov.isLoading) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));

                    List<Map<String, dynamic>> data = _vistaActual == 0 ? prov.reporteMensual : prov.reporteDiario;
                    
                    // Aplicar Filtros
                    if (_tiendaFiltro != 'ALL') {
                      data = data.where((r) => r['tienda'] == _tiendaFiltro).toList();
                    }
                    if (_filtroBuscador.isNotEmpty) {
                      data = data.where((r) => 
                        (_vistaActual == 0 ? r['mes'].toString() : r['dia']).toLowerCase().contains(_filtroBuscador)
                      ).toList();
                    }
                    if (_rangoFechas != null && _vistaActual == 1) {
                      data = data.where((r) {
                        try {
                          final f = DateTime.parse(r['dia']);
                          return f.isAfter(_rangoFechas!.start.subtract(const Duration(days: 1))) && f.isBefore(_rangoFechas!.end.add(const Duration(days: 1)));
                        } catch(_) { return true; }
                      }).toList();
                    }

                    if (data.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No hay datos registrados.')));

                    double totalIng = 0;
                    double totalEgr = 0;
                    for (var r in data) {
                      totalIng += (r['ingresos'] as num).toDouble();
                      totalEgr += (r['egresos'] as num).toDouble();
                    }

                    return Column(
                      children: [
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(width: isMobile ? double.infinity : 250, child: _kpiCard('Ingresos Totales', totalIng, Colors.green, dev.isDevMode)),
                            SizedBox(width: isMobile ? double.infinity : 250, child: _kpiCard('Egresos Totales', totalEgr, dev.isDevMode ? AppColors.nebulaPink : Colors.red, dev.isDevMode)),
                            SizedBox(width: isMobile ? double.infinity : 250, child: _kpiCard('Balance Global', totalIng - totalEgr, Colors.blue, dev.isDevMode)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: dev.isDevMode ? Colors.white.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: dev.isDevMode ? Colors.white10 : AppColors.gray200)
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(dev.isDevMode ? Colors.white10 : AppColors.primaryLight.withOpacity(0.3)),
                              dataTextStyle: TextStyle(color: dev.isDevMode ? Colors.white : Colors.black87),
                              columns: [
                                DataColumn(label: Text(_vistaActual == 0 ? 'Año' : 'Fecha')),
                                if (_vistaActual == 0) const DataColumn(label: Text('Mes')),
                                const DataColumn(label: Text('Tienda')),
                                const DataColumn(label: Text('Ingresos')),
                                const DataColumn(label: Text('Egresos')),
                                const DataColumn(label: Text('Balance')),
                              ],
                              rows: data.map((r) {
                                final ing = (r['ingresos'] as num).toDouble();
                                final egr = (r['egresos'] as num).toDouble();
                                final bal = ing - egr;
                                
                                List<DataCell> cells = [];
                                if (_vistaActual == 0) {
                                  cells.add(DataCell(Text('${r['anio']}')));
                                  cells.add(DataCell(Text('${r['mes']}')));
                                } else {
                                  cells.add(DataCell(Text('${r['dia']}')));
                                }
                                
                                cells.addAll([
                                  DataCell(Text('${r['tienda']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text('S/ ${ing.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green))),
                                  DataCell(Text('S/ ${egr.toStringAsFixed(2)}', style: TextStyle(color: dev.isDevMode ? AppColors.nebulaPink : Colors.red))),
                                  DataCell(Text('S/ ${bal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: bal >= 0 ? Colors.blue : (dev.isDevMode ? AppColors.nebulaPink : Colors.red)))),
                                ]);

                                return DataRow(cells: cells);
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, int index, bool isDev) {
    bool selected = _vistaActual == index;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _vistaActual = index),
      selectedColor: isDev ? AppColors.nebulaPurple : AppColors.primary,
      backgroundColor: isDev ? Colors.white.withOpacity(0.05) : Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : (isDev ? Colors.white54 : AppColors.gray600)),
    );
  }

  Widget _buildTiendaChip(String tienda, bool isDev) {
    bool selected = _tiendaFiltro == tienda;
    return ChoiceChip(
      label: Text(tienda),
      selected: selected,
      onSelected: (_) => setState(() => _tiendaFiltro = tienda),
      selectedColor: isDev ? AppColors.nebulaPink : Colors.orange,
      backgroundColor: isDev ? Colors.white.withOpacity(0.05) : Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : (isDev ? Colors.white54 : AppColors.gray600)),
    );
  }

  Widget _kpiCard(String title, double value, Color color, bool isDev) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDev ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDev ? Colors.white10 : AppColors.gray200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: isDev ? Colors.white70 : AppColors.gray500, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('S/ ${value.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
