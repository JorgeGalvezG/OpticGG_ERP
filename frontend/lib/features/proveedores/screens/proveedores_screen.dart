import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/proveedor_model.dart';
import '../providers/proveedores_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../caja/providers/caja_provider.dart';
import '../../caja/models/nuevo_movimiento_dto.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ProveedoresProvider>(
        context,
        listen: false,
      ).fetchProveedores(auth.tienda ?? 'C1');
      // También cargamos caja para el historial
      Provider.of<CajaProvider>(
        context,
        listen: false,
      ).fetchMovimientos(auth.tienda ?? 'C1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

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
                  const Text(
                    'Proveedores',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (!isMobile) const SizedBox(height: 4),
                  if (!isMobile)
                    const Text(
                      'Directorio de laboratorios y compras',
                      style: TextStyle(fontSize: 14, color: AppColors.gray500),
                    ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const _NuevoProveedorDialog(),
                ),
                icon: const Icon(Icons.domain_add_rounded, size: 18),
                label: isMobile
                    ? const Text('Nuevo')
                    : const Text('Nuevo Proveedor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),

        // LISTA DE PROVEEDORES
        Expanded(
          child: Consumer<ProveedoresProvider>(
            builder: (context, prov, child) {
              if (prov.isLoading)
                return const Center(child: CircularProgressIndicator());
              if (prov.proveedores.isEmpty)
                return const Center(
                  child: Text(
                    'No hay proveedores registrados',
                    style: TextStyle(color: AppColors.gray500),
                  ),
                );

              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ).copyWith(bottom: 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile
                      ? 1.6
                      : 1.4, // Ajustado para botones
                ),
                itemCount: prov.proveedores.length,
                itemBuilder: (context, index) {
                  final p = prov.proveedores[index];
                  return _buildProveedorCard(p);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProveedorCard(Proveedor p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p.nombreEmpresa,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                size: 14,
                color: AppColors.gray400,
              ),
              const SizedBox(width: 6),
              Text(
                p.nombreContacto ?? 'Sin contacto',
                style: const TextStyle(fontSize: 13, color: AppColors.gray600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.phone_rounded,
                size: 14,
                color: AppColors.gray400,
              ),
              const SizedBox(width: 6),
              Text(
                p.telefono ?? 'Sin teléfono',
                style: const TextStyle(fontSize: 13, color: AppColors.gray600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.gray100),
          const SizedBox(height: 12),
          // BOTONES DE ACCIÓN
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          _HistorialComprasDialog(proveedor: p),
                    );
                  },
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: const Text(
                    'Historial',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray700,
                    side: const BorderSide(color: AppColors.gray200),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => _PagoProveedorDialog(proveedor: p),
                    );
                  },
                  icon: const Icon(Icons.payment_rounded, size: 16),
                  label: const Text('Comprar', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger.withOpacity(0.1),
                    foregroundColor: AppColors.danger,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================
// MODAL: Historial de Compras del Proveedor
// =========================================================
class _HistorialComprasDialog extends StatelessWidget {
  final Proveedor proveedor;

  const _HistorialComprasDialog({required this.proveedor});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 600,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historial de Compras',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        proveedor.nombreEmpresa,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Consumer<CajaProvider>(
                builder: (context, cajaProv, child) {
                  // Filtramos los movimientos de SALIDA que contengan el nombre del proveedor
                  final compras = cajaProv.movimientos.where((m) {
                    return m.tipo == 'SALIDA' &&
                        m.descripcion.toLowerCase().contains(
                          proveedor.nombreEmpresa.toLowerCase(),
                        );
                  }).toList();

                  if (compras.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay compras registradas.',
                        style: TextStyle(color: AppColors.gray500),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: compras.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.gray100),
                    itemBuilder: (context, index) {
                      final compra = compras[index];
                      // Limpiamos el texto para mostrar solo el detalle del usuario
                      final detalle = compra.descripcion.replaceAll(
                        'Pago a laboratorio/proveedor: ${proveedor.nombreEmpresa} - ',
                        '',
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_rounded,
                                color: AppColors.danger,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detalle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    compra.fecha.substring(0, 10),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.gray500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '- S/ ${compra.monto.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// FORMULARIO: Registrar Pago a Proveedor (Conecta con Caja)
// =========================================================
class _PagoProveedorDialog extends StatefulWidget {
  final Proveedor proveedor;

  const _PagoProveedorDialog({required this.proveedor});

  @override
  State<_PagoProveedorDialog> createState() => _PagoProveedorDialogState();
}

class _PagoProveedorDialogState extends State<_PagoProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Lo dejamos vacío para que el vendedor TENGA que escribir qué compró
    _descripcionController.text = '';
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
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
                    const Text(
                      'Registrar Compra',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proveedor: ${widget.proveedor.nombreEmpresa}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Monto S/ *',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _montoController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.monetization_on_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Monto requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Qué se compró? (Resinas, monturas, etc) *',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Ej: 10 Resinas AR, 5 Monturas RayBan...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Detalle requerido' : null,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.gray200)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final auth = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        final dto = NuevoMovimientoDTO(
                          tipo: 'SALIDA',
                          monto:
                              double.tryParse(_montoController.text.trim()) ??
                              0.0,
                          descripcion:
                              'Pago a laboratorio/proveedor: ${widget.proveedor.nombreEmpresa} - ${_descripcionController.text.trim()}',
                          usuarioId: 1,
                          // Usar ID real del usuario si es posible
                          tienda: auth.tienda ?? 'C1',
                        );

                        final exito = await Provider.of<CajaProvider>(
                          context,
                          listen: false,
                        ).registrarMovimiento(dto);
                        if (!context.mounted) return;

                        if (exito) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pago registrado en Caja'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Confirmar Egreso',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// FORMULARIO: Registrar Nuevo Proveedor
// =========================================================
class _NuevoProveedorDialog extends StatefulWidget {
  const _NuevoProveedorDialog();

  @override
  State<_NuevoProveedorDialog> createState() => _NuevoProveedorDialogState();
}

class _NuevoProveedorDialogState extends State<_NuevoProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _empresaController = TextEditingController();
  final _contactoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _rucController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuevo Proveedor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _empresaController,
                decoration: const InputDecoration(labelText: 'Empresa *'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactoController,
                decoration: const InputDecoration(labelText: 'Contacto'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rucController,
                decoration: const InputDecoration(labelText: 'RUC'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final auth = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final p = Proveedor(
                          nombreEmpresa: _empresaController.text.trim(),
                          nombreContacto: _contactoController.text.trim(),
                          telefono: _telefonoController.text.trim(),
                          ruc: _rucController.text.trim(),
                          tienda: auth.tienda ?? 'C1',
                        );
                        final exito = await Provider.of<ProveedoresProvider>(
                          context,
                          listen: false,
                        ).crearProveedor(p);
                        if (exito && mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
