import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/shared/responsive.dart';
import '../../../core/shared/developer_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/config_provider.dart';
import '../screens/dashboard_screen.dart';
import '../../caja/screens/caja_screen.dart';
import '../../ventas/screens/ventas_screen.dart';
import '../../pacientes/screens/pacientes_screen.dart';
import '../../proveedores/screens/proveedores_screen.dart';
import '../../almacen/screens/almacen_screen.dart';
import '../../almacen/screens/categorias_screen.dart';
import '../../vip/screens/vip_screen.dart';
import '../../usuarios/screens/usuarios_screen.dart';
import '../screens/reportes_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.tienda != null) {
        Provider.of<ConfigProvider>(context, listen: false).cargarConfig(auth.tienda!);
      }
    });
  }

  List<Widget> get _screens => [
    const DashboardScreen(), // 0
    const CajaScreen(), // 1
    const AlmacenScreen(), // 2
    const PacientesScreen(), // 3
    const VentasScreen(), // 4
    const ProveedoresScreen(), // 5
    const VipScreen(), // 6
    const UsuariosScreen(), // 7
    const CategoriasScreen(), // 8
    const ReportesScreen(), // 9 (Historial General)
    const _AuditPanel(), // 10
  ];

  final List<String> _titles = [
    'Inicio',
    'Caja y Movimientos',
    'Almacén e Inventario',
    'Pacientes',
    'Ventas',
    'Proveedores',
    'Clientes VIP',
    'Gestión de Personal',
    'Categorías de Productos',
    'Historial General (Reportes)',
    '🔎 Auditoría de Sistemas',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dev = Provider.of<DeveloperProvider>(context);

    return Responsive(
      mobile: _buildMobileLayout(auth, dev),
      desktop: _buildDesktopLayout(auth, dev),
    );
  }

  // =======================================================
  // 📱 DISEÑO MÓVIL
  // =======================================================
  Widget _buildMobileLayout(AuthProvider auth, DeveloperProvider dev) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _selectedIndex == 0 ? 'Gestor OCC' : _titles[_selectedIndex],
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: _buildDrawer(auth, dev),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Caja'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Almacén'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Pacientes'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'Más'),
        ],
      ),
    );
  }

  Widget _buildDrawer(AuthProvider auth, DeveloperProvider dev) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(gradient: dev.isDevMode ? AppColors.nebulaGradient : AppColors.loginGradient),
            accountName: Text(auth.username ?? 'Usuario'),
            accountEmail: Text('${auth.rol}${dev.isDevMode ? " • MODO DEV" : ""}'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(auth.username?[0].toUpperCase() ?? 'U', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_rounded),
            title: const Text('Ventas / Órdenes'),
            selected: _selectedIndex == 4,
            onTap: () { setState(() => _selectedIndex = 4); Navigator.pop(context); },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_rounded),
            title: const Text('Proveedores'),
            selected: _selectedIndex == 5,
            onTap: () { setState(() => _selectedIndex = 5); Navigator.pop(context); },
          ),
          if (auth.rol == 'ADMIN') ...[
            ListTile(
              leading: const Icon(Icons.badge_rounded),
              title: const Text('Gestión de Personal'),
              selected: _selectedIndex == 7,
              onTap: () { setState(() => _selectedIndex = 7); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.category_rounded),
              title: const Text('Categorías'),
              selected: _selectedIndex == 8,
              onTap: () { setState(() => _selectedIndex = 8); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_rounded),
              title: const Text('Historial (Reportes)'),
              selected: _selectedIndex == 9,
              onTap: () { setState(() => _selectedIndex = 9); Navigator.pop(context); },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.star_rounded, color: Colors.orange),
            title: const Text('Clientes VIP'),
            selected: _selectedIndex == 6,
            onTap: () { setState(() => _selectedIndex = 6); Navigator.pop(context); },
          ),
          if (dev.isDevMode)
            ListTile(
              leading: const Icon(Icons.troubleshoot_rounded, color: AppColors.nebulaPink),
              title: const Text('Auditoría Dev'),
              selected: _selectedIndex == 10,
              onTap: () { setState(() => _selectedIndex = 10); Navigator.pop(context); },
            ),
          const Spacer(),
          const Divider(),
          SwitchListTile(
            title: const Text('Modo Desarrollador', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            value: dev.isDevMode,
            onChanged: (v) => dev.toggleDevMode(),
            secondary: const Icon(Icons.code_rounded),
          ),
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
  Widget _buildDesktopLayout(AuthProvider auth, DeveloperProvider dev) {
    return Scaffold(
      body: Row(
        children: [
          _buildDesktopSidebar(auth, dev),
          Expanded(
            child: Column(
              children: [
                _buildDesktopHeader(auth, dev),
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

  Widget _buildDesktopHeader(AuthProvider auth, DeveloperProvider dev) {
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gray900),
          ),
          Row(
            children: [
              if (dev.isDevMode)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.nebulaPink.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.nebulaPink)),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppColors.nebulaPink),
                      SizedBox(width: 6),
                      Text('DEV MODE ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.nebulaPink)),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(8)),
                child: Text('Sucursal: ${auth.tienda ?? "C1"}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray700)),
              ),
              const SizedBox(width: 16),
              IconButton(icon: const Icon(Icons.notifications_none_rounded, color: AppColors.gray500), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(AuthProvider auth, DeveloperProvider dev) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 250,
      decoration: BoxDecoration(gradient: dev.isDevMode ? AppColors.nebulaGradient : AppColors.loginGradient),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(dev.isDevMode ? Icons.auto_awesome : Icons.remove_red_eye, color: Colors.white, size: 40),
          const Text('Gestor OCC', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          if (dev.isDevMode) const Text('COSMIC EDITION', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 30),

          _buildSidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),
          _buildSidebarItem(1, Icons.account_balance_wallet_rounded, 'Caja'),
          _buildSidebarItem(2, Icons.inventory_2_rounded, 'Almacén'),
          _buildSidebarItem(3, Icons.people_alt_rounded, 'Pacientes'),
          _buildSidebarItem(4, Icons.shopping_bag_rounded, 'Ventas'),
          _buildSidebarItem(5, Icons.local_shipping_rounded, 'Proveedores'),

          if (auth.rol == 'ADMIN') ...[
            const Padding(
              padding: EdgeInsets.only(left: 24, top: 20, bottom: 10),
              child: Align(alignment: Alignment.centerLeft, child: Text('ADMINISTRACIÓN', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold))),
            ),
            _buildSidebarItem(6, Icons.star_rounded, 'Clientes VIP'),
            _buildSidebarItem(7, Icons.badge_rounded, 'Personal'),
            _buildSidebarItem(8, Icons.category_rounded, 'Categorías'),
            _buildSidebarItem(9, Icons.analytics_rounded, 'Historial (Reportes)'),
          ],
          
          if (dev.isDevMode) ...[
             const Padding(
              padding: EdgeInsets.only(left: 24, top: 20, bottom: 10),
              child: Align(alignment: Alignment.centerLeft, child: Text('DEVELOPER TOOLS', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold))),
            ),
            _buildSidebarItem(10, Icons.troubleshoot_rounded, 'Auditoría'),
          ],

          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                const Text('MODO DEV', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                const Spacer(),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: dev.isDevMode, 
                    activeColor: AppColors.nebulaPink,
                    onChanged: (v) => dev.toggleDevMode()
                  ),
                ),
              ],
            ),
          ),
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
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}

// =========================================================
// 🚀 PANEL DE AUDITORÍA (SOLO MODO DEV)
// =========================================================
class _AuditPanel extends StatefulWidget {
  const _AuditPanel();
  @override
  State<_AuditPanel> createState() => _AuditPanelState();
}

class _AuditPanelState extends State<_AuditPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeveloperProvider>(context, listen: false).fetchAuditReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeveloperProvider>(
      builder: (context, dev, _) {
        if (dev.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.nebulaPurple));
        
        final report = dev.auditReport;
        if (report == null) return const Center(child: Text('Error al cargar reporte de auditoría'));

        final List<dynamic> inconsistencies = report['inconsistencies'] ?? [];

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estado de Integridad de Datos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Ejecutar Scripts'),
                      onPressed: () => dev.fetchAuditReport(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.nebulaPurple, foregroundColor: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _auditStatCard('Ventas Huérfanas', report['orphanedSales'].toString(), report['orphanedSales'] > 0 ? AppColors.danger : AppColors.success, Icons.shopping_basket_rounded),
                    const SizedBox(width: 16),
                    _auditStatCard('Stock Negativo', report['stockMismatches'].toString(), report['stockMismatches'] > 0 ? AppColors.warning : AppColors.success, Icons.inventory_2_rounded),
                    const SizedBox(width: 16),
                    _auditStatCard('Descalce de Saldos', report['balanceMismatches'].toString(), report['balanceMismatches'] > 0 ? AppColors.danger : AppColors.success, Icons.account_balance_wallet_rounded),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('DETALLES TÉCNICOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray500)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray200)),
                  child: inconsistencies.isEmpty 
                    ? const Row(children: [Icon(Icons.check_circle, color: AppColors.success), SizedBox(width: 12), Text('¡Perfecto! No se encontraron inconsistencias en la base de datos.')])
                    : Column(
                        children: inconsistencies.map((i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18), const SizedBox(width: 12), Text(i.toString(), style: const TextStyle(fontSize: 13))]),
                        )).toList(),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _auditStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          ],
        ),
      ),
    );
  }
}
