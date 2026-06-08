import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/almacen_provider.dart';
import '../models/almacen_model.dart';

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
      Provider.of<AlmacenProvider>(context, listen: false).fetchProductos(tienda);
    });
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
                onPressed: () {
                  // TODO: Abrir dialogo de nuevo producto
                },
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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Icon(Icons.image_not_supported_rounded, size: 40, color: AppColors.gray400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.categoriaNombre ?? 'Sin Categoría', style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
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