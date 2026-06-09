import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/proveedor_model.dart';
import '../providers/proveedores_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../caja/providers/caja_provider.dart';
import '../../caja/models/nuevo_movimiento_dto.dart';
import '../../almacen/providers/almacen_provider.dart';
import '../../almacen/models/almacen_model.dart';

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
      Provider.of<ProveedoresProvider>(context, listen: false).fetchProveedores(auth.tienda ?? 'C1');
      Provider.of<CajaProvider>(context, listen: false).fetchMovimientos(auth.tienda ?? 'C1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Proveedores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gray900)),
                  Text('Directorio de laboratorios y compras detalladas', style: TextStyle(fontSize: 14, color: AppColors.gray500)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showDialog(context: context, barrierDismissible: false, builder: (context) => const _NuevoProveedorDialog()),
                icon: const Icon(Icons.domain_add_rounded, size: 18),
                label: Text(isMobile ? 'Nuevo' : 'Nuevo Proveedor'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<ProveedoresProvider>(
            builder: (context, prov, child) {
              if (prov.isLoading) return const Center(child: CircularProgressIndicator());
              if (prov.proveedores.isEmpty) return const Center(child: Text('No hay proveedores registrados', style: TextStyle(color: AppColors.gray500)));

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 1.6 : 1.4,
                ),
                itemCount: prov.proveedores.length,
                itemBuilder: (context, index) => _buildProveedorCard(prov.proveedores[index]),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.primaryLight, child: const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Text(p.nombreEmpresa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.person_rounded, p.nombreContacto ?? 'Sin contacto'),
          const SizedBox(height: 6),
          _infoRow(Icons.phone_rounded, p.telefono ?? 'Sin teléfono'),
          const Spacer(),
          const Divider(height: 1, color: AppColors.gray100),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Historial', style: TextStyle(fontSize: 12)))),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => showDialog(context: context, barrierDismissible: false, builder: (context) => _CompraDetalladaDialog(proveedor: p)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger.withOpacity(0.1), foregroundColor: AppColors.danger, elevation: 0),
                  child: const Text('Comprar', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(children: [Icon(icon, size: 14, color: AppColors.gray400), const SizedBox(width: 6), Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray600))]);
}

class _CompraDetalladaDialog extends StatefulWidget {
  final Proveedor proveedor;
  const _CompraDetalladaDialog({required this.proveedor});

  @override
  State<_CompraDetalladaDialog> createState() => _CompraDetalladaDialogState();
}

class _CompraDetalladaDialogState extends State<_CompraDetalladaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montoPagadoController = TextEditingController(text: '0');
  final _descripcionController = TextEditingController();
  final List<Map<String, dynamic>> _itemsCompra = [];
  double _totalCompra = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<AlmacenProvider>(context, listen: false).fetchProductos(auth.tienda ?? 'C1');
    });
  }

  void _recalcularTotal() {
    double total = 0;
    for (var item in _itemsCompra) {
      total += (item['cantidad'] as int) * (item['precioUnitario'] as double);
    }
    setState(() => _totalCompra = total);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 600, height: 750, padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nueva Compra a Proveedor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proveedor: ${widget.proveedor.nombreEmpresa}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 20),
                      const Text('1. Buscar Productos en Almacén', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      _buildBuscador(),
                      const SizedBox(height: 16),
                      const Text('Lista de Ítems:', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                      _buildItemsList(),
                      const Divider(height: 40),
                      const Text('2. Resumen Financiero', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _statBox('TOTAL', 'S/ ${_totalCompra.toStringAsFixed(2)}', AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(child: TextFormField(controller: _montoPagadoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto Pagado S/'), validator: (v) => v!.isEmpty ? 'Requerido' : null)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _confirmar, child: const Text('Registrar Compra y Stock'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuscador() {
    return Consumer<AlmacenProvider>(
      builder: (context, prov, _) => Autocomplete<Almacen>(
        displayStringForOption: (p) => p.nombre,
        optionsBuilder: (text) => text.text.isEmpty ? const Iterable.empty() : prov.productos.where((p) => p.nombre.toLowerCase().contains(text.text.toLowerCase())),
      onSelected: (p) {
        setState(() {
          _itemsCompra.add({'almacenId': p.id, 'nombre': p.nombre, 'cantidad': 1, 'precioUnitario': p.precioCompra});
          _recalcularTotal();
        });
      },
      fieldViewBuilder: (ctx, ctrl, focus, onFieldSubmitted) => TextField(
        controller: ctrl,
        focusNode: focus,
        decoration: InputDecoration(
          hintText: 'Buscar o escanear...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_box_rounded, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sugerencia: Use la pestaña Almacén para dar de alta productos nuevos primero.')));
            },
          ),
          border: const OutlineInputBorder()
        ),
      ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (_itemsCompra.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No hay productos seleccionados')));
    return Column(
      children: _itemsCompra.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return ListTile(
          title: Text(item['nombre'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: Text('Costo: S/ ${item['precioUnitario']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() { if (item['cantidad'] > 1) item['cantidad']--; else _itemsCompra.removeAt(i); _recalcularTotal(); })),
              Text('${item['cantidad']}'),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() { item['cantidad']++; _recalcularTotal(); })),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _statBox(String l, String v, Color c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: c)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c)), Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c))]));

  void _confirmar() async {
    if (!_formKey.currentState!.validate() || _itemsCompra.isEmpty) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final prov = Provider.of<ProveedoresProvider>(context, listen: false);
    final dto = {
      'proveedorId': widget.proveedor.id,
      'montoTotal': _totalCompra,
      'montoPagado': double.tryParse(_montoPagadoController.text) ?? 0,
      'descripcion': 'Compra detallada a ${widget.proveedor.nombreEmpresa}',
      'tienda': auth.tienda ?? 'C1',
      'items': _itemsCompra.map((i) => {'almacenId': i['almacenId'], 'cantidad': i['cantidad'], 'precioUnitario': i['precioUnitario']}).toList(),
    };
    final exito = await prov.registrarNuevaCompra(dto);
    if (exito && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compra registrada correctamente'), backgroundColor: AppColors.success));
    }
  }
}

class _NuevoProveedorDialog extends StatefulWidget {
  const _NuevoProveedorDialog();
  @override
  State<_NuevoProveedorDialog> createState() => _NuevoProveedorDialogState();
}

class _NuevoProveedorDialogState extends State<_NuevoProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _empresaController = TextEditingController();
  final _rucController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24), width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nuevo Proveedor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(controller: _empresaController, decoration: const InputDecoration(labelText: 'Empresa *'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _rucController, decoration: const InputDecoration(labelText: 'RUC')),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: _guardar, child: const Text('Guardar'))]),
            ],
          ),
        ),
      ),
    );
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final p = Proveedor(nombreEmpresa: _empresaController.text.trim(), ruc: _rucController.text.trim(), tienda: auth.tienda ?? 'C1');
      final exito = await Provider.of<ProveedoresProvider>(context, listen: false).crearProveedor(p);
      if (exito && mounted) Navigator.pop(context);
    }
  }
}
