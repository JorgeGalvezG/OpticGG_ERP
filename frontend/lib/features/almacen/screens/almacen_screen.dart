import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/api_service.dart';
import '../providers/almacen_provider.dart';
import '../models/almacen_model.dart';

import '../../proveedores/providers/proveedores_provider.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AlmacenScreen extends StatefulWidget {
  const AlmacenScreen({super.key});

  @override
  State<AlmacenScreen> createState() => _AlmacenScreenState();
}

class _AlmacenScreenState extends State<AlmacenScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tienda = Provider.of<AuthProvider>(context, listen: false).tienda ?? 'C1';
      final prov = Provider.of<AlmacenProvider>(context, listen: false);
      prov.fetchProductos(tienda);
      prov.fetchCategorias();
      // También cargar proveedores para el combo
      Provider.of<ProveedoresProvider>(context, listen: false).fetchProveedores(tienda);
    });
  }

  void _showProductoDialog(BuildContext context, {Almacen? producto}) {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(text: producto?.nombre);
    final codigoCtrl = TextEditingController(text: producto?.codigoBarras);
    final stockCtrl = TextEditingController(text: producto?.stock.toString() ?? '0');
    final precioVentaCtrl = TextEditingController(text: producto?.precioVenta.toString() ?? '0');
    final precioCompraCtrl = TextEditingController(text: producto?.precioCompra.toString() ?? '0');
    int? selectedCategoriaId = producto?.categoriaId;
    int? selectedProveedorId = producto?.proveedorId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(producto == null ? 'Nuevo Producto / Montura' : 'Editar Producto', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre del Producto *', prefixIcon: Icon(Icons.shopping_bag_outlined)),
                      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: codigoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Código de Barras *',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                        suffixIcon: Icon(Icons.camera_alt_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Consumer<AlmacenProvider>(
                            builder: (context, prov, _) => DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Categoría *', prefixIcon: Icon(Icons.category_rounded)),
                              value: selectedCategoriaId,
                              items: prov.categorias.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (v) => setDialogState(() => selectedCategoriaId = v),
                              validator: (v) => v == null ? 'Seleccione' : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer<ProveedoresProvider>(
                            builder: (context, prov, _) => DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Proveedor', prefixIcon: Icon(Icons.local_shipping_rounded)),
                              value: selectedProveedorId,
                              items: prov.proveedores.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreEmpresa, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (v) => setDialogState(() => selectedProveedorId = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Stock Inicial', prefixIcon: Icon(Icons.inventory_rounded)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: precioCompraCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Precio Compra S/', prefixIcon: Icon(Icons.shopping_cart_rounded)),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: precioVentaCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Precio Venta S/ (Sugerido)', prefixIcon: Icon(Icons.sell_rounded)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final auth = Provider.of<AuthProvider>(context, listen: false);
                final prov = Provider.of<AlmacenProvider>(context, listen: false);

                final data = {
                  'nombre': nombreCtrl.text,
                  'codigoBarras': codigoCtrl.text,
                  'categoria': {'id': selectedCategoriaId},
                  'proveedor': selectedProveedorId != null ? {'id': selectedProveedorId} : null,
                  'stock': int.tryParse(stockCtrl.text) ?? 0,
                  'precioCompra': double.tryParse(precioCompraCtrl.text) ?? 0,
                  'precioVenta': double.tryParse(precioVentaCtrl.text) ?? 0,
                  'fotoUrl': producto?.fotoUrl ?? 'https://cdn-icons-png.flaticon.com/512/3081/3081986.png',
                  'tienda': auth.tienda ?? 'C1',
                };

                bool exito;
                if (producto == null) {
                  exito = await prov.guardarProducto(data);
                } else {
                  exito = await prov.actualizarProducto(producto.id!, data);
                }

                if (exito) {
                  Navigator.pop(context);
                  prov.fetchProductos(auth.tienda ?? 'C1');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(producto == null ? 'Producto guardado' : 'Producto actualizado'), backgroundColor: AppColors.success));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final almacenProv = Provider.of<AlmacenProvider>(context);
    final productosFiltrados = almacenProv.productos.where((p) {
      return p.nombre.toLowerCase().contains(_filter.toLowerCase()) || 
             p.codigoBarras.contains(_filter);
    }).toList();

    return Column(
      children: [
        // CABECERA
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Almacén e Inventario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Gestión de productos, monturas y stock', style: TextStyle(fontSize: 14, color: AppColors.gray500)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showProductoDialog(context),
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Nuevo Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),

        // BUSCADOR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _filter = v),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o código de barras...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner_rounded),
                onPressed: () {
                  // TODO: Integrar scanner de codigo de barras
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // LISTADO
        Expanded(
          child: almacenProv.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : productosFiltrados.isEmpty 
              ? const Center(child: Text('No hay productos en inventario'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final p = productosFiltrados[index];
                      return _ProductCard(producto: p);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Almacen producto;
  const _ProductCard({required this.producto});

  @override
  Widget build(BuildContext context) {
    final String fullFotoUrl = ApiService.getFullUrl(producto.fotoUrl);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(image: NetworkImage(fullFotoUrl), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                      onPressed: () {
                        final state = context.findAncestorStateOfType<_AlmacenScreenState>();
                        state?._showProductoDialog(context, producto: producto);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(producto.categoriaNombre ?? 'Sin Categoría', style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    if (producto.proveedorNombre != null)
                      Text(producto.proveedorNombre!, style: const TextStyle(fontSize: 8, color: AppColors.gray400)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stock: ${producto.stock}', style: TextStyle(color: producto.stock < 5 ? AppColors.danger : AppColors.success, fontWeight: FontWeight.bold)),
                    Text('S/ ${producto.precioVenta.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Cód: ${producto.codigoBarras}', style: const TextStyle(fontSize: 10, color: AppColors.gray500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}