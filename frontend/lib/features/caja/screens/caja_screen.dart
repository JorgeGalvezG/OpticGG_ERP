import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../providers/caja_provider.dart';
import '../models/nuevo_movimiento_dto.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/shared/developer_provider.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({super.key});

  @override
  State<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  String _filtroTexto = '';
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tienda = Provider.of<AuthProvider>(context, listen: false).tienda ?? 'C1';
      Provider.of<CajaProvider>(context, listen: false).fetchMovimientos(tienda);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABECERA
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Caja y Movimientos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gray900)),
                    if (!isMobile) const SizedBox(height: 4),
                    if (!isMobile) const Text('Control de ingresos y salidas de dinero', style: TextStyle(fontSize: 14, color: AppColors.gray500)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => showDialog(context: context, barrierDismissible: false, builder: (context) => const _NuevoMovimientoDialog()),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Nuevo Registro'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                )
              ],
            ),
          ),

          // BUSCADOR Y FILTROS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por descripción...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() => _filtroTexto = v),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
                    if (picked != null) setState(() => _rangoFechas = picked);
                  },
                  icon: const Icon(Icons.date_range_rounded),
                  label: Text(_rangoFechas == null ? 'Filtrar Fecha' : 'Filtrado'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (_rangoFechas != null)
                  IconButton(icon: const Icon(Icons.clear_rounded, color: AppColors.danger), onPressed: () => setState(() => _rangoFechas = null)),
              ],
            ),
          ),

          // CONTENIDO CONECTADO AL PROVIDER
          Consumer<CajaProvider>(
            builder: (context, cajaProv, child) {
              final dev = Provider.of<DeveloperProvider>(context);

              if (cajaProv.isLoading && cajaProv.movimientos.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
              }

              final movimientosFiltrados = cajaProv.movimientos.where((m) {
                final matchTexto = m.descripcion.toLowerCase().contains(_filtroTexto.toLowerCase());
                bool matchFecha = true;
                if (_rangoFechas != null) {
                  try {
                    final fecha = DateTime.parse(m.fecha);
                    matchFecha = fecha.isAfter(_rangoFechas!.start) && fecha.isBefore(_rangoFechas!.end.add(const Duration(days: 1)));
                  } catch (_) {}
                }
                return matchTexto && matchFecha;
              }).toList();

              return Stack(
                children: [
                  if (dev.isDevMode) Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.spaceGradient))),
                  Column(
                    children: [
                      // 1. TARJETAS DE RESUMEN (Glassmorphic in Dev Mode)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: isMobile
                            ? Column(
                          children: [
                            _buildResumenCard('Saldo Actual', cajaProv.saldoActual, AppColors.primary, Icons.account_balance_wallet_rounded, isMobile, dev.isDevMode),
                            const SizedBox(height: 12),
                            _buildResumenCard('Ingresos', cajaProv.totalIngresos, AppColors.success, Icons.arrow_upward_rounded, isMobile, dev.isDevMode),
                            const SizedBox(height: 12),
                            _buildResumenCard('Salidas', cajaProv.totalSalidas, AppColors.danger, Icons.arrow_downward_rounded, isMobile, dev.isDevMode),
                          ],
                        )
                            : Row(
                          children: [
                            Expanded(child: _buildResumenCard('Saldo Actual (Caja)', cajaProv.saldoActual, AppColors.primary, Icons.account_balance_wallet_rounded, isMobile, dev.isDevMode)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildResumenCard('Ingresos', cajaProv.totalIngresos, AppColors.success, Icons.arrow_upward_rounded, isMobile, dev.isDevMode)),    
                            const SizedBox(width: 12),
                            Expanded(child: _buildResumenCard('Salidas', cajaProv.totalSalidas, AppColors.danger, Icons.arrow_downward_rounded, isMobile, dev.isDevMode)),     
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. LISTA DE MOVIMIENTOS
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 24.0),
                        decoration: BoxDecoration(
                          color: dev.isDevMode ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: dev.isDevMode ? Colors.white10 : AppColors.gray200)
                        ),
                        child: movimientosFiltrados.isEmpty
                            ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('No hay movimientos que coincidan con los filtros', style: TextStyle(color: dev.isDevMode ? Colors.white38 : AppColors.gray500))))
                            : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: movimientosFiltrados.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: dev.isDevMode ? Colors.white10 : AppColors.gray100),
                          itemBuilder: (context, index) {
                            final mov = movimientosFiltrados[index];
                            final isIngreso = mov.tipo == 'ENTRADA';
                            final color = isIngreso ? AppColors.success : (dev.isDevMode ? AppColors.nebulaPink : AppColors.danger);

                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(isIngreso ? Icons.add_rounded : Icons.remove_rounded, color: color)),
                                title: Text(mov.descripcion, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: dev.isDevMode ? Colors.white : AppColors.gray900)),
                                subtitle: Text('${mov.fecha.length >= 10 ? mov.fecha.substring(0, 10) : mov.fecha}  •  Usuario: ${mov.usuarioNombre}', style: TextStyle(fontSize: 12, color: dev.isDevMode ? Colors.white38 : AppColors.gray500)),
                                trailing: Text('${isIngreso ? '+' : '-'} S/ ${mov.monto.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard(String title, double monto, Color color, IconData icon, bool isMobile, bool isDev) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDev ? 10 : 0, sigmaY: isDev ? 10 : 0),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: isDev ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDev ? Colors.white10 : AppColors.gray200),
            boxShadow: isDev ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: isMobile ? 24 : 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: isMobile ? 12 : 14, color: isDev ? Colors.white70 : AppColors.gray500, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('S/ ${monto.toStringAsFixed(2)}', style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: isDev ? Colors.white : AppColors.gray900)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _NuevoMovimientoDialog extends StatefulWidget {
  const _NuevoMovimientoDialog();
  @override
  State<_NuevoMovimientoDialog> createState() => _NuevoMovimientoDialogState();
}

class _NuevoMovimientoDialogState extends State<_NuevoMovimientoDialog> {
  final _formKey = GlobalKey<FormState>();
  String _tipoSeleccionado = 'ENTRADA';
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 500,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Registrar Movimiento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _tipoSeleccionado = 'ENTRADA'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: _tipoSeleccionado == 'ENTRADA' ? AppColors.success.withOpacity(0.1) : Colors.white, border: Border.all(color: _tipoSeleccionado == 'ENTRADA' ? AppColors.success : AppColors.gray200), borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text('INGRESO (+)', style: TextStyle(fontWeight: FontWeight.bold, color: _tipoSeleccionado == 'ENTRADA' ? AppColors.success : AppColors.gray500))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _tipoSeleccionado = 'SALIDA'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: _tipoSeleccionado == 'SALIDA' ? AppColors.danger.withOpacity(0.1) : Colors.white, border: Border.all(color: _tipoSeleccionado == 'SALIDA' ? AppColors.danger : AppColors.gray200), borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text('GASTO (-)', style: TextStyle(fontWeight: FontWeight.bold, color: _tipoSeleccionado == 'SALIDA' ? AppColors.danger : AppColors.gray500))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Monto S/ *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _montoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: 'S/ ',
                        prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Descripción o Motivo *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 2,
                      decoration: InputDecoration(hintText: 'Ej: Compra de papel para impresora...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.gray200))),
                child: SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final auth = Provider.of<AuthProvider>(context, listen: false);

                        final dto = NuevoMovimientoDTO(
                          tipo: _tipoSeleccionado,
                          monto: double.tryParse(_montoController.text.trim()) ?? 0.0,
                          descripcion: _descripcionController.text.trim(),
                          usuarioId: 1, 
                          tienda: auth.tienda ?? 'C1',
                        );

                        final exito = await Provider.of<CajaProvider>(context, listen: false).registrarMovimiento(dto);
                        if (!context.mounted) return;

                        if (exito) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movimiento registrado'), backgroundColor: AppColors.success));
                        }
                      }
                    },
                    child: const Text('Guardar Registro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
