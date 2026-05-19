import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../usuarios/screens/usuarios_screen.dart';

class MobileMenuScreen extends StatelessWidget {
  // Recibimos un callback para poder cambiar de pantalla desde aquí
  final Function(int) onNavigate;

  const MobileMenuScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Perfil del Usuario
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppColors.loginGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.primary, radius: 28, child: const Text('AD', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Administrador', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Todas las tiendas', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Opciones Administrativas (Que no caben en la barra inferior)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ADMINISTRACIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray400, letterSpacing: 1)),
                const SizedBox(height: 12),

                // Estos botones cambiarán el índice del MainLayout
                _MenuOption(icon: Icons.local_shipping_rounded, title: 'Proveedores y Laboratorios', color: AppColors.primary, onTap: () => onNavigate(4)),
                const SizedBox(height: 12),
                _MenuOption(icon: Icons.star_rounded, title: 'Clientes VIP / Convenios', color: AppColors.warning, onTap: () => onNavigate(5)),
                const SizedBox(height: 12),
                _MenuOption(icon: Icons.badge_rounded, title: 'Gestión de Personal', color: AppColors.gray900, onTap: () => onNavigate(6)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(height: 1, color: AppColors.gray200),
                ),

                const Text('CUENTA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray400, letterSpacing: 1)),
                const SizedBox(height: 12),
                _MenuOption(icon: Icons.settings_rounded, title: 'Configuración de Tienda', color: AppColors.gray600, onTap: () {}),
                const SizedBox(height: 12),
                _MenuOption(icon: Icons.logout_rounded, title: 'Cerrar Sesión', color: AppColors.danger, onTap: () {}),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon; final String title; final Color color; final VoidCallback onTap;
  const _MenuOption({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray200)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.gray800))),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.gray300, size: 16),
          ],
        ),
      ),
    );
  }
}