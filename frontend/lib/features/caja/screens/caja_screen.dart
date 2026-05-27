import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/caja_provider.dart';
import '../models/nuevo_movimiento_dto.dart';
import '../../auth/providers/auth_provider.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({super.key});

  @override
  State<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CABECERA
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

        // CONTENIDO CONECTADO AL PROVIDER
        Expanded(
          child: Consumer<CajaProvider>(
            builder: (context, cajaProv, child) {
              if (cajaProv.isLoading && cajaProv.movimientos.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // 1. TARJETAS DE RESUMEN
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: isMobile
                        ? Column(
                      children: [
                        _buildResumenCard('Saldo Actual', cajaProv.saldoActual, AppColors.primary, Icons.account_balance_wallet_rounded, isMobile),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildResumenCard('Ingresos', cajaProv.totalIngresos, AppColors.success, Icons.arrow_downward_rounded, isMobile)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildResumenCard('Salidas', cajaProv.totalSalidas, AppColors.danger, Icons.arrow_upward_rounded, isMobile)),
                          ],
                        )
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(child: _buildResumenCard('Saldo Actual (Caja)', cajaProv.saldoActual, AppColors.primary, Icons.account_balance_wallet_rounded, isMobile)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildResumenCard('Total Ingresos', cajaProv.totalIngresos, AppColors.success, Icons.arrow_downward_rounded, isMobile)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildResumenCard('Total Salidas (Gastos)', cajaProv.totalSalidas, AppColors.danger, Icons.arrow_upward_rounded, isMobile)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. LISTA DE MOVIMIENTOS
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 24.0),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray200)),
                      child: cajaProv.movimientos.isEmpty
                          ? const Center(child: Text('No hay movimientos registrados', style: TextStyle(color: AppColors.gray500)))
                          : ListView.separated(
                        itemCount: cajaProv.movimientos.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.gray100),
                        itemBuilder: (context, index) {
                          final mov = cajaProv.movimientos[index];
                          final isIngreso = mov.tipo == 'ENTRADA';
                          final color = isIngreso ? AppColors.success : AppColors.danger;

                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(isIngreso ? Icons.add_rounded : Icons.remove_rounded, color: color)),
                              title: Text(mov.descripcion, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('${mov.fecha.length >= 10 ? mov.fecha.substring(0, 10) : mov.fecha}  •  Usuario: ${mov.usuarioNombre}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                              trailing: Text('${isIngreso ? '+' : '-'} S/ ${mov.monto.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResumenCard(String title, double monto, Color color, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: isMobile ? 24 : 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: isMobile ? 12 : 14, color: AppColors.gray500, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('S/ ${monto.toStringAsFixed(2)}', style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: AppColors.gray900)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// =========================================================
// FORMULARIO: Registrar Gasto o Ingreso
// =========================================================
class _NuevoMovimientoDialog extends StatefulWidget {
  const _NuevoMovimientoDialog();
  @override
  State<_NuevoMovimientoDialog> createState() => _NuevoMovimientoDialogState();
}

class _NuevoMovimientoDialogState extends State<_NuevoMovimientoDialog> {
  final _formKey = GlobalKey<FormState>();
  String _tipoSeleccionado = 'ENTRADA'; // Por defecto registramos una entrada
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
                    // Selector de Tipo de Movimiento
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
                          usuarioId: 1, // TODO: Aquí debes poner el ID real del usuario logueado
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