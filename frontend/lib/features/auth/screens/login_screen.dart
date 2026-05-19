import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isAdmin = true;
  String _selectedStore = 'C1';

  void _submitLogin() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa usuario y contraseña'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(user, pass);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos o servidor apagado'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 850; // Ajusté un poco el punto de quiebre

    return Scaffold(
      backgroundColor: isDesktop ? AppColors.gray900 : null,
      body: Container(
        width: double.infinity,
        decoration: isDesktop ? null : const BoxDecoration(gradient: AppColors.loginGradient),
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  // =========================================================
  // 💻 DISEÑO PARA PC (Con el panel derecho MEJORADO)
  // =========================================================
  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 860,
        height: 560, // Un poco más alto para que respiren las nuevas tarjetas
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 50, offset: Offset(0, 20))],
        ),
        child: Row(
          children: [
            // Mitad Izquierda: Formulario
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: _buildFormContent(),
              ),
            ),
            // Mitad Derecha: Panel Premium "Llamativo"
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                child: Stack(
                  children: [
                    // 1. Fondo Gradiente
                    Container(decoration: const BoxDecoration(gradient: AppColors.loginGradient)),

                    // 2. Elementos decorativos (Círculos abstractos) para romper lo genérico
                    Positioned(
                      top: -60, right: -40,
                      child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.03))),
                    ),
                    Positioned(
                      bottom: -80, left: -60,
                      child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05), width: 2))),
                    ),

                    // 3. Contenido (Textos y Tarjetas Glass)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gestión completa\npara tu óptica', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5)),
                          const SizedBox(height: 12),
                          Text('ERP con historial clínico, ventas, órdenes automáticas y caja integrada.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5)),
                          const SizedBox(height: 36),

                          // Las nuevas tarjetas "Glassmorphism"
                          const _GlassFeatureCard(
                            icon: Icons.auto_awesome_mosaic_rounded,
                            title: 'Órdenes automáticas',
                            desc: 'Al registrar una venta, la orden se genera sola.',
                          ),
                          const SizedBox(height: 16),
                          const _GlassFeatureCard(
                            icon: Icons.timeline_rounded,
                            title: 'Timeline del paciente',
                            desc: 'Historial clínico y compras en una sola vista.',
                          ),
                          const SizedBox(height: 16),
                          const _GlassFeatureCard(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Caja integrada',
                            desc: 'Pagos a proveedores se reflejan como salidas.',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 📱 DISEÑO PARA CELULAR
  // =========================================================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        const Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Icon(Icons.remove_red_eye, color: Colors.white, size: 56),
              SizedBox(height: 16),
              Text('OpticGG', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              Text('ERP · Sistema de Gestión Óptica', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: _buildFormContent(),
        ),
      ],
    );
  }

  // =========================================================
  // EL FORMULARIO REUTILIZABLE
  // =========================================================
  Widget _buildFormContent() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDesktop) ...[
            Row(
              children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.remove_red_eye, color: Colors.white))),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('OpticGG', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gray900, letterSpacing: -0.5)), Text('ERP · Sistema de Gestión', style: TextStyle(fontSize: 12, color: AppColors.gray400))]),
              ],
            ),
            const SizedBox(height: 40),
          ],

          const Text('Bienvenido 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.gray900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          const Text('Ingresa con tu cuenta para continuar', style: TextStyle(color: AppColors.gray500, fontSize: 14)),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _buildRoleTab('👑 Admin', true)),
                Expanded(child: _buildRoleTab('🛍️ Vendedor', false)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Usuario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray700)),
          const SizedBox(height: 8),
          TextField(
            controller: _userController,
            decoration: InputDecoration(
              hintText: 'Ej: admin',
              filled: true, fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Contraseña', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray700)),
          const SizedBox(height: 8),
          TextField(
            controller: _passController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '••••••••',
              filled: true, fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),

          if (!_isAdmin) ...[
            const Text('Tienda asignada', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStore,
              decoration: InputDecoration(
                filled: true, fillColor: AppColors.gray50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
              ),
              items: ['C1', 'C2', 'C3'].map((String value) => DropdownMenuItem<String>(value: value, child: Text('Tienda $value'))).toList(),
              onChanged: (newValue) => setState(() => _selectedStore = newValue!),
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 12),

          Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: auth.isLoading ? null : _submitLogin,
                    child: auth.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Ingresar al sistema', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.3)),
                  ),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab(String title, bool isThisAdmin) {
    final isActive = _isAdmin == isThisAdmin;
    return GestureDetector(
      onTap: () => setState(() => _isAdmin = isThisAdmin),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))] : [],
        ),
        child: Center(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isActive ? AppColors.primary : AppColors.gray500))),
      ),
    );
  }
}

// =========================================================
// NUEVA TARJETA "GLASSMORPHISM" PARA LOS FEATURES
// =========================================================
class _GlassFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _GlassFeatureCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06), // Fondo translúcido
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1), // Borde de cristal
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}