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

class _CompraDetalladaDialogState extends State<_CompraDetalladaDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _montoPagadoController = TextEditingController(text: '0');
  
  // Lista para stock (Pestana 1)
  final List<Map<String, dynamic>> _itemsAlmacen = [];
  
  // Lista para gasto directo (Pestana 2)
  final List<Map<String, dynamic>> _itemsDirectos = [];
  final _nombreGastoCtrl = TextEditingController();
  final _precioGastoCtrl = TextEditingController();

  double _totalCompra = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<AlmacenProvider>(context, listen: false).fetchProductos(auth.tienda ?? 'C1');
    });
  }

  void _recalcularTotal() {
    double total = 0;
    for (var item in _itemsAlmacen) {
      total += (item['cantidad'] as int) * (item['precioUnitario'] as double);
    }
    for (var item in _itemsDirectos) {
      total += (item['cantidad'] as int) * (item['precioUnitario'] as double);
    }
    setState(() => _totalCompra = total);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 700, height: 850, padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nueva Compra a Proveedor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(widget.proveedor.nombreEmpresa, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.gray400,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.inventory_2_rounded), text: 'STOCK ALMACÉN'),
                  Tab(icon: Icon(Icons.auto_fix_high_rounded), text: 'LUNAS / GASTO DIRECTO'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPestanaStock(),
                    _buildPestanaGastoDirecto(),
                  ],
                ),
              ),
              const Divider(height: 32),
              _buildResumenFinanciero(),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: _confirmar, 
                  child: const Text('Confirmar Pedido y Registrar Pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPestanaStock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Buscar producto existente en Almacén:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildBuscadorAlmacen(),
        const SizedBox(height: 16),
        const Text('Ítems para Stock:', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
        Expanded(child: _buildItemsList(_itemsAlmacen)),
      ],
    );
  }

  Widget _buildPestanaGastoDirecto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registrar compra de lunas o servicios especiales (No van a stock):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(flex: 2, child: TextFormField(controller: _nombreGastoCtrl, decoration: const InputDecoration(labelText: 'Descripción (Ej: Par Lunas Blue Defense)', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _precioGastoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio Compra S/', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.success, size: 40),
              onPressed: () {
                if (_nombreGastoCtrl.text.isEmpty || _precioGastoCtrl.text.isEmpty) return;
                setState(() {
                  _itemsDirectos.add({
                    'almacenId': null, // Indica que no es de almacén
                    'nombre': _nombreGastoCtrl.text,
                    'cantidad': 1,
                    'precioUnitario': double.tryParse(_precioGastoCtrl.text) ?? 0,
                  });
                  _nombreGastoCtrl.clear();
                  _precioGastoCtrl.clear();
                  _recalcularTotal();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Ítems Directos:', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
        Expanded(child: _buildItemsList(_itemsDirectos)),
      ],
    );
  }

  Widget _buildBuscadorAlmacen() {
    return Consumer<AlmacenProvider>(
      builder: (context, prov, _) => Autocomplete<Almacen>(
        displayStringForOption: (p) => p.nombre,
        optionsBuilder: (text) => text.text.isEmpty ? const Iterable.empty() : prov.productos.where((p) => p.nombre.toLowerCase().contains(text.text.toLowerCase()) || p.codigoBarras.contains(text.text)),
        onSelected: (p) {
          setState(() {
            _itemsAlmacen.add({'almacenId': p.id, 'nombre': p.nombre, 'cantidad': 1, 'precioUnitario': p.precioCompra});
            _recalcularTotal();
          });
        },
        fieldViewBuilder: (ctx, ctrl, focus, onFieldSubmitted) => TextField(controller: ctrl, focusNode: focus, decoration: const InputDecoration(hintText: 'Buscar por nombre o código...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
      ),
    );
  }

  Widget _buildItemsList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return const Center(child: Text('No hay productos agregados', style: TextStyle(fontSize: 12, color: AppColors.gray400)));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return ListTile(
          dense: true,
          title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Unitario: S/ ${item['precioUnitario']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() { if (item['cantidad'] > 1) item['cantidad']--; else list.removeAt(index); _recalcularTotal(); })),
              Text('${item['cantidad']}'),
              IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() { item['cantidad']++; _recalcularTotal(); })),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumenFinanciero() {
    return Row(
      children: [
        Expanded(child: _infoBox('TOTAL PEDIDO', 'S/ ${_totalCompra.toStringAsFixed(2)}', AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _montoPagadoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto a Cuenta S/', prefixIcon: Icon(Icons.payments_rounded), border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String l, String v, Color c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: c)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c)), Text(v, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: c))]));

  void _confirmar() async {
    if (!_formKey.currentState!.validate() || (_itemsAlmacen.isEmpty && _itemsDirectos.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agregue productos a la compra')));
      return;
    }
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final prov = Provider.of<ProveedoresProvider>(context, listen: false);
    
    // Unir ambas listas para el DTO
    final allItems = [..._itemsAlmacen, ..._itemsDirectos];

    final dto = {
      'proveedorId': widget.proveedor.id,
      'montoTotal': _totalCompra,
      'montoPagado': double.tryParse(_montoPagadoController.text) ?? 0,
      'descripcion': 'Compra detallada: ${_itemsAlmacen.length} stock, ${_itemsDirectos.length} directos',
      'tienda': auth.tienda ?? 'C1',
      'items': allItems.map((i) => {
        'almacenId': i['almacenId'], // Puede ser null
        'cantidad': i['cantidad'],
        'precioUnitario': i['precioUnitario'],
      }).toList(),
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
