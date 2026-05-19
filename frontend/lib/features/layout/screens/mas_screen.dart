import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Más Opciones', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gray900)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuOpcion(
              context,
              titulo: 'Proveedores',
              subtitulo: 'Gestión de laboratorios y marcas',
              icono: Icons.local_shipping_rounded,
              color: Colors.blue,
              onTap: () {
                // TODO: Navegar a pantalla de Proveedores
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ir a Proveedores')));
              }
          ),
          const SizedBox(height: 12),
          _buildMenuOpcion(
              context,
              titulo: 'Pacientes VIP',
              subtitulo: 'Fidelización y clientes recurrentes',
              icono: Icons.star_rounded,
              color: AppColors.warning,
              onTap: () {
                // TODO: Navegar a pantalla VIP
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ir a Pacientes VIP')));
              }
          ),
          const SizedBox(height: 12),
          _buildMenuOpcion(
              context,
              titulo: 'Caja y Movimientos',
              subtitulo: 'Ingresos y salidas de dinero',
              icono: Icons.point_of_sale_rounded,
              color: Colors.green,
              onTap: () {}
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOpcion(BuildContext context, {required String titulo, required String subtitulo, required IconData icono, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray200)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icono, color: color)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.gray900)), const SizedBox(height: 4), Text(subtitulo, style: const TextStyle(fontSize: 13, color: AppColors.gray500))])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}