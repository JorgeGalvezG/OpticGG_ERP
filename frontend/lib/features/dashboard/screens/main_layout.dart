import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/shared/responsive.dart';
import '../../auth/providers/auth_provider.dart';
import '../screens/dashboard_screen.dart';
import '../../caja/screens/caja_screen.dart';
import '../../ventas/screens/ventas_screen.dart';
import '../../pacientes/screens/pacientes_screen.dart';
import '../../proveedores/screens/proveedores_screen.dart';
import '../../vip/screens/vip_screen.dart';
import '../../usuarios/screens/usuarios_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Definición de pantallas por índice
  List<Widget> get _screens => [
    const DashboardScreen(), // 0
    const CajaScreen(), // 1
    const PacientesScreen(), // 2
    const VentasScreen(), // 3
    const ProveedoresScreen(), // 4
    const VipScreen(), // 5
    const UsuariosScreen(), // 6
  ];

  final List<String> _titles = [
    'Inicio',
    'Caja y Movimientos',
    'Pacientes',
    'Ventas',
    'Proveedores',
    'Clientes VIP',
    'Gestión de Personal',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Responsive(
      mobile: _buildMobileLayout(auth),
      desktop: _buildDesktopLayout(auth),
    );
  }

  // =======================================================
  // 📱 DISEÑO MÓVIL
  // =======================================================
  Widget _buildMobileLayout(AuthProvider auth) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Menú lateral para móvil (Aquí es donde agregamos Proveedores y VIP)
      drawer: _buildDrawer(auth),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
        // Reset si está en una oculta
        onTap: (index) {
          if (index == 4) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Caja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'Más',
          ),
        ],
      ),
    );
  }

  // WIDGET: EL MENÚ LATERAL (DRAWER) MÓVIL
  Widget _buildDrawer(AuthProvider auth) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(gradient: AppColors.loginGradient),
            accountName: Text(auth.username ?? 'Usuario'),
            accountEmail: Text(auth.rol ?? 'Rol'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                auth.username?[0].toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_rounded),
            title: const Text('Proveedores'),
            selected: _selectedIndex == 4,
            onTap: () {
              setState(() => _selectedIndex = 4);
              Navigator.pop(context);
            },
          ),

          if (auth.rol == 'ADMIN')
            ListTile(
              leading: const Icon(Icons.badge_rounded),
              title: const Text('Gestión de Personal'),
              selected: _selectedIndex == 6,
              onTap: () {
                setState(() => _selectedIndex = 6);
                Navigator.pop(context);
              },
            ),
          ListTile(
            leading: const Icon(Icons.star_rounded, color: Colors.orange),
            title: const Text('Clientes VIP'),
            selected: _selectedIndex == 5,
            onTap: () {
              setState(() => _selectedIndex = 5);
              Navigator.pop(context);
            },
          ),

          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
            title: const Text('Cerrar Sesión'),
            onTap: () => auth.logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =======================================================
  // 💻 DISEÑO PC
  // =======================================================
  Widget _buildDesktopLayout(AuthProvider auth) {
    return Scaffold(
      body: Row(
        children: [
          _buildDesktopSidebar(auth),
          Expanded(
            child: Column(
              children: [
                _buildDesktopHeader(auth),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(AuthProvider auth) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sucursal: ${auth.tienda ?? "C1"}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.gray500,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(AuthProvider auth) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(gradient: AppColors.loginGradient),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo
          const Icon(Icons.remove_red_eye, color: Colors.white, size: 40),
          const Text(
            'OpticGG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          _buildSidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),
          _buildSidebarItem(1, Icons.account_balance_wallet_rounded, 'Caja'),
          _buildSidebarItem(2, Icons.people_alt_rounded, 'Pacientes'),
          _buildSidebarItem(3, Icons.shopping_bag_rounded, 'Ventas'),
          _buildSidebarItem(4, Icons.local_shipping_rounded, 'Proveedores'),

          if (auth.rol == 'ADMIN') ...[
            const Padding(
              padding: EdgeInsets.only(left: 24, top: 20, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ADMINISTRACIÓN',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildSidebarItem(5, Icons.star_rounded, 'Clientes VIP'),
            _buildSidebarItem(6, Icons.badge_rounded, 'Personal'),
          ],
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.white70),
            title: const Text('Salir', style: TextStyle(color: Colors.white)),
            onTap: () => auth.logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.white10,
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white60),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}
