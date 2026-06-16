import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/almacen_provider.dart';
import '../models/categoria_model.dart';
import '../../../core/shared/developer_provider.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlmacenProvider>(context, listen: false).fetchCategorias();
    });
  }

  void _showCategoriaDialog({CategoriaProducto? categoria}) {
    final nombreCtrl = TextEditingController(text: categoria?.nombre);
    String clasificacion = categoria?.clasificacion ?? 'OTROS';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(categoria == null ? 'Nueva Categoría' : 'Editar Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: clasificacion,
                decoration: const InputDecoration(labelText: 'Clasificación'),
                items: ['LENTES', 'OTROS'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setDialogState(() => clasificacion = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nombreCtrl.text.isEmpty) return;
                final prov = Provider.of<AlmacenProvider>(context, listen: false);
                final data = {'nombre': nombreCtrl.text, 'clasificacion': clasificacion};
                
                bool exito;
                if (categoria == null) {
                  exito = await prov.guardarCategoria(data);
                } else {
                  exito = await prov.actualizarCategoria(categoria.id!, data);
                }

                if (exito && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Categoría guardada')));
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
    final dev = Provider.of<DeveloperProvider>(context);
    
    return Stack(
      children: [
        if (dev.isDevMode) Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.spaceGradient))),
        Padding(
          padding: const EdgeInsets.all(24.0),
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
                      Text('Gestión de Categorías', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: dev.isDevMode ? Colors.white : AppColors.gray900)),
                      Text('Clasifique sus productos para un mejor control', style: TextStyle(fontSize: 14, color: dev.isDevMode ? Colors.white38 : AppColors.gray500)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoriaDialog(),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Nueva Categoría'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer<AlmacenProvider>(
                  builder: (context, prov, _) {
                    if (prov.categorias.isEmpty) return const Center(child: Text('No hay categorías registradas'));
                    return ListView.builder(
                      itemCount: prov.categorias.length,
                      itemBuilder: (context, index) {
                        final cat = prov.categorias[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: dev.isDevMode ? Colors.white.withOpacity(0.05) : Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cat.clasificacion == 'LENTES' ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              child: Icon(cat.clasificacion == 'LENTES' ? Icons.visibility : Icons.category, color: cat.clasificacion == 'LENTES' ? Colors.blue : Colors.orange),
                            ),
                            title: Text(cat.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: dev.isDevMode ? Colors.white : AppColors.gray900)),
                            subtitle: Text('Clasificación: ${cat.clasificacion}', style: TextStyle(color: dev.isDevMode ? Colors.white38 : AppColors.gray500)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showCategoriaDialog(categoria: cat)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red), 
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Eliminar Categoría'),
                                        content: const Text('¿Está seguro? Esto podría afectar a los productos vinculados.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await prov.eliminarCategoria(cat.id!);
                                    }
                                  }
                                ),
                              ],
                            ),
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
      ],
    );
  }
}
