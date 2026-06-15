import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../models/proveedor_model.dart';
import '../models/compra_proveedor_model.dart';
import '../providers/proveedores_provider.dart';
import '../../../core/shared/developer_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../caja/providers/caja_provider.dart';
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
    final dev = Provider.of<DeveloperProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Stack(
      children: [
        if (dev.isDevMode) Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.spaceGradient))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proveedores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: dev.isDevMode ? Colors.white : AppColors.gray900)),
                      Text('Directorio de laboratorios y compras detalladas', style: TextStyle(fontSize: 14, color: dev.isDevMode ? Colors.white38 : AppColors.gray500)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showDialog(context: context, barrierDismissible: false, builder: (context) => const _NuevoProveedorDialog()),
                    icon: const Icon(Icons.domain_add_rounded, size: 18),
                    label: Text(isMobile ? 'Nuevo' : 'Nuevo Proveedor'),
                    style: ElevatedButton.styleFrom(backgroundColor: dev.isDevMode ? AppColors.nebulaPurple : AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ProveedoresProvider>(
                builder: (context, prov, child) {
                  if (prov.isLoading) return Center(child: CircularProgressIndicator(color: dev.isDevMode ? AppColors.nebulaPurple : AppColors.primary));
                  if (prov.proveedores.isEmpty) return Center(child: Text('No hay proveedores registrados', style: TextStyle(color: dev.isDevMode ? Colors.white38 : AppColors.gray500)));

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isMobile ? 1.6 : 1.4,
                    ),
                    itemCount: prov.proveedores.length,
                    itemBuilder: (context, index) => _buildProveedorCard(prov.proveedores[index], dev.isDevMode),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProveedorCard(Proveedor p, bool isDev) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDev ? 10 : 0, sigmaY: isDev ? 10 : 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDev ? Colors.white.withOpacity(0.05) : Colors.white, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: isDev ? Colors.white10 : AppColors.gray200)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: isDev ? AppColors.nebulaPurple.withOpacity(0.2) : AppColors.primaryLight, child: Icon(Icons.apartment_rounded, color: isDev ? AppColors.starlight : AppColors.primary, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(p.nombreEmpresa, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDev ? Colors.white : AppColors.gray900), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: Icon(Icons.edit_rounded, size: 18, color: isDev ? AppColors.starlight : AppColors.primary),
                    onPressed: () => showDialog(context: context, builder: (context) => _NuevoProveedorDialog(proveedor: p)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (p.contactos.isNotEmpty)
                ...p.contactos.take(2).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: _infoRow(Icons.person_outline_rounded, '${c.nombre} (${c.telefono ?? "S/T"})', isDev),
                ))
              else
                _infoRow(Icons.person_off_rounded, 'Sin contactos', isDev),
              const Spacer(),
              Divider(height: 1, color: isDev ? Colors.white10 : AppColors.gray100),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => showDialog(context: context, builder: (context) => _HistorialComprasDialog(proveedor: p)), style: OutlinedButton.styleFrom(side: BorderSide(color: isDev ? Colors.white24 : AppColors.gray300), foregroundColor: isDev ? Colors.white70 : AppColors.gray700), child: const Text('Historial', style: TextStyle(fontSize: 12)))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => showDialog(context: context, barrierDismissible: false, builder: (context) => _CompraDetalladaDialog(proveedor: p)),
                      style: ElevatedButton.styleFrom(backgroundColor: isDev ? AppColors.nebulaPink.withOpacity(0.2) : AppColors.danger.withOpacity(0.1), foregroundColor: isDev ? AppColors.nebulaPink : AppColors.danger, elevation: 0),
                      child: const Text('Comprar', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isDev) => Row(children: [Icon(icon, size: 14, color: isDev ? Colors.white38 : AppColors.gray400), const SizedBox(width: 6), Text(text, style: TextStyle(fontSize: 13, color: isDev ? Colors.white70 : AppColors.gray600))]);
}

class _HistorialComprasDialog extends StatefulWidget {
  final Proveedor proveedor;
  const _HistorialComprasDialog({required this.proveedor});

  @override
  State<_HistorialComprasDialog> createState() => _HistorialComprasDialogState();
}

class _HistorialComprasDialogState extends State<_HistorialComprasDialog> {
  String _filtroTexto = '';
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProveedoresProvider>(context, listen: false).fetchHistorialCompras(widget.proveedor.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 800, height: 700, padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Historial de Compras', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(widget.proveedor.nombreEmpresa, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Buscar por descripción...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
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
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18)),
                ),
                if (_rangoFechas != null)
                  IconButton(icon: const Icon(Icons.clear_rounded, color: AppColors.danger), onPressed: () => setState(() => _rangoFechas = null)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<ProveedoresProvider>(
                builder: (context, prov, child) {
                  if (prov.isLoading) return const Center(child: CircularProgressIndicator());
                  
                  final filtered = prov.historialCompras.where((c) {
                    final matchTexto = c.descripcion.toLowerCase().contains(_filtroTexto.toLowerCase()) || c.id.toString().contains(_filtroTexto);
                    bool matchFecha = true;
                    if (_rangoFechas != null) {
                      try {
                        final fecha = DateTime.parse(c.fechaPedido);
                        matchFecha = fecha.isAfter(_rangoFechas!.start) && fecha.isBefore(_rangoFechas!.end.add(const Duration(days: 1)));
                      } catch (_) {}
                    }
                    return matchTexto && matchFecha;
                  }).toList();

                  if (filtered.isEmpty) return const Center(child: Text('No se encontraron compras con los filtros aplicados.'));

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.gray200)),
                        elevation: 0,
                        child: ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(c.titulo ?? 'Compra #${c.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                              _badgeEstado(c.estadoPago),
                            ],
                          ),
                          subtitle: Text('ID: #${c.id}  •  Fecha: ${c.fechaPedido}  •  Total: S/ ${c.monto.toStringAsFixed(2)}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Descripción: ${c.descripcion}', style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 8),
                                  const Text('Productos Detallados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  if (c.detalles != null)
                                    ...c.detalles!.map((d) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${d.cantidad}x ${d.productoNombre}', style: const TextStyle(fontSize: 12)),
                                          Text('S/ ${(d.cantidad * d.precioUnitario).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    )),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Saldo Pendiente: S/ ${c.montoSaldo.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                                      if (c.estadoEntrega == 'SOLICITADO')
                                        ElevatedButton(
                                          onPressed: () async {
                                            final exito = await prov.registrarEntrega(c.id);
                                            if (exito) prov.fetchHistorialCompras(widget.proveedor.id!);
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0)),
                                          child: const Text('Marcar Llegada', style: TextStyle(fontSize: 10)),
                                        ),
                                    ],
                                  ),
                                ],
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

  Widget _badgeEstado(String estado) {
    final color = estado == 'PAGADO' ? AppColors.success : AppColors.warning;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(estado, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
  }
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
  final _tituloController = TextEditingController(text: 'Compra de Lentes');
  final _montoPagadoController = TextEditingController(text: '0');
  
  final List<Map<String, dynamic>> _itemsAlmacen = [];
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

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    _montoPagadoController.dispose();
    _nombreGastoCtrl.dispose();
    _precioGastoCtrl.dispose();
    super.dispose();
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
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título de la Compra (Ej: Compra Anual de Lunas)', prefixIcon: Icon(Icons.label_important_rounded), border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
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
                    'almacenId': null,
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
    
    final allItems = [..._itemsAlmacen, ..._itemsDirectos];

    final dto = {
      'proveedorId': widget.proveedor.id,
      'montoTotal': _totalCompra,
      'montoPagado': double.tryParse(_montoPagadoController.text) ?? 0,
      'descripcion': 'Compra detallada: ${_itemsAlmacen.length} stock, ${_itemsDirectos.length} directos',
      'tienda': auth.tienda ?? 'C1',
      'items': allItems.map((i) => {
        'almacenId': i['almacenId'],
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
  final Proveedor? proveedor;
  const _NuevoProveedorDialog({this.proveedor});
  @override
  State<_NuevoProveedorDialog> createState() => _NuevoProveedorDialogState();
}

class _NuevoProveedorDialogState extends State<_NuevoProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _empresaController = TextEditingController();
  final _rucController = TextEditingController();
  
  List<ProveedorContacto> _contactos = [];

  @override
  void initState() {
    super.initState();
    if (widget.proveedor != null) {
      _empresaController.text = widget.proveedor!.nombreEmpresa;
      _rucController.text = widget.proveedor!.ruc ?? '';
      _contactos = List.from(widget.proveedor!.contactos);
    }
    if (_contactos.isEmpty) {
      _contactos.add(ProveedorContacto(nombre: '', cargo: 'Principal'));
    }
  }

  @override
  void dispose() {
    _empresaController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dev = Provider.of<DeveloperProvider>(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24), width: 550,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.proveedor == null ? 'Nuevo Proveedor' : 'Editar Proveedor', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _empresaController, 
                  decoration: const InputDecoration(labelText: 'Nombre de la Empresa *', prefixIcon: Icon(Icons.business_rounded), border: OutlineInputBorder()), 
                  validator: (v) => v!.isEmpty ? 'Requerido' : null
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rucController, 
                  decoration: const InputDecoration(labelText: 'RUC', prefixIcon: Icon(Icons.badge_rounded), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Personas de Contacto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    TextButton.icon(
                      onPressed: () => setState(() => _contactos.add(ProveedorContacto(nombre: ''))),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Añadir Contacto', style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                ..._contactos.asMap().entries.map((entry) {
                  int idx = entry.key;
                  ProveedorContacto c = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray200)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: TextFormField(
                              initialValue: c.nombre,
                              decoration: const InputDecoration(labelText: 'Nombre', isDense: true),
                              onChanged: (v) => _contactos[idx] = ProveedorContacto(id: c.id, nombre: v, telefono: c.telefono, cargo: c.cargo),
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: TextFormField(
                              initialValue: c.cargo,
                              decoration: const InputDecoration(labelText: 'Cargo (Opcional)', isDense: true),
                              onChanged: (v) => _contactos[idx] = ProveedorContacto(id: c.id, nombre: c.nombre, telefono: c.telefono, cargo: v),
                            )),
                            IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20), onPressed: () => setState(() => _contactos.removeAt(idx))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: c.telefono,
                          decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp', prefixIcon: Icon(Icons.phone, size: 16), isDense: true),
                          onChanged: (v) => _contactos[idx] = ProveedorContacto(id: c.id, nombre: c.nombre, telefono: v, cargo: c.cargo),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _guardar, 
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(widget.proveedor == null ? 'Crear Proveedor' : 'Guardar Cambios')
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final provProv = Provider.of<ProveedoresProvider>(context, listen: false);
      
      final p = Proveedor(
        id: widget.proveedor?.id,
        nombreEmpresa: _empresaController.text.trim(), 
        ruc: _rucController.text.trim(), 
        tienda: auth.tienda ?? 'C1',
        contactos: _contactos.where((c) => c.nombre.isNotEmpty).toList(),
      );

      bool exito;
      if (widget.proveedor == null) {
        exito = await provProv.crearProveedor(p);
      } else {
        exito = await provProv.actualizarProveedor(p);
      }

      if (exito && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.proveedor == null ? 'Proveedor creado' : 'Proveedor actualizado'), backgroundColor: AppColors.success));
      }
    }
  }
}
