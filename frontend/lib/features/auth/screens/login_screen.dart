import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('saved_username');
    final savedPass = prefs.getString('saved_password');

    if (savedUser != null && savedPass != null) {
      setState(() {
        _userController.text = savedUser;
        _passController.text = savedPass;
        _rememberMe = true;
      });
    }
  }

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
    final success = await auth.login(user, pass, rememberMe: _rememberMe);

    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_username', user);
        await prefs.setString('saved_password', pass);
      } else {
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos o servidor apagado'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 850;

    return Scaffold(
      backgroundColor: AppColors.gray900,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isDesktop ? null : AppColors.loginGradient,
        ),
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  // =========================================================
  //  DISEÑO PARA PC (Con BANNER DE IMAGEN)
  // =========================================================
  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 1000,
        height: 650,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 50, offset: const Offset(0, 20))],
        ),
        child: Row(
          children: [
            // Mitad Izquierda: Formulario
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
                child: _buildFormContent(),
              ),
            ),
            // Mitad Derecha: Banner de Imagen
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(32)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1591076482161-42ce6da69f67?auto=format&fit=crop&q=80&w=1000',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(decoration: const BoxDecoration(gradient: AppColors.loginGradient)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 40),
                          SizedBox(height: 16),
                          Text('Centro Óptico Cubas 20/20', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold, letterSpacing: -1)),
                          Text('Solución integral para la gestión de tu óptica.', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ),
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
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1591076482161-42ce6da69f67?auto=format&fit=crop&q=80&w=1000',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(decoration: const BoxDecoration(gradient: AppColors.loginGradient)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 80),
                    SizedBox(height: 16),
                    Text('Centro Óptico Cubas 20/20', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -2)),
                    Text('SISTEMA DE GESTIÓN INTEGRAL', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 64),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
    final isDesktop = MediaQuery.of(context).size.width > 850;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) ...[
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 28)),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Centro Óptico Cubas 20/20', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gray900)),
                    Text('GESTIÓN EMPRESARIAL', style: TextStyle(fontSize: 10, color: AppColors.gray400, letterSpacing: 1)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],

          const Text('Bienvenido al Sistema', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.gray900)),
          const SizedBox(height: 6),
          const Text('Por favor, inicia sesión para continuar.', style: TextStyle(color: AppColors.gray500, fontSize: 15)),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _buildRoleTab('Administrador', true)),
                Expanded(child: _buildRoleTab('Vendedores por tienda', false)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _buildLabel('Usuario'),
          TextField(
            controller: _userController,
            decoration: _inputStyle(Icons.person_outline, 'Ej: admin'),
          ),
          const SizedBox(height: 20),

          _buildLabel('Contraseña'),
          TextField(
            controller: _passController,
            obscureText: _obscurePassword, // ← DINÁMICO
            decoration: _inputStyle(
              Icons.lock_outline, 
              '••••••••',
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.gray400),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (!_isAdmin) ...[
            _buildLabel('Tienda asignada'),
            DropdownButtonFormField<String>(
              value: _selectedStore,
              decoration: _inputStyle(Icons.storefront_outlined, ''),
              items: ['C1', 'C2', 'C3'].map((String value) => DropdownMenuItem<String>(value: value, child: Text('Tienda $value'))).toList(),
              onChanged: (newValue) => setState(() => _selectedStore = newValue!),
            ),
            const SizedBox(height: 20),
          ],

          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                activeColor: AppColors.primary,
              ),
              const Text('Recordar usuario y contraseña', style: TextStyle(color: AppColors.gray700, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),

          Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: auth.isLoading ? null : _submitLogin,
                    child: auth.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Ingresar al sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray700)),
    );
  }

  InputDecoration _inputStyle(IconData icon, String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.gray400),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.gray50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
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
        child: Center(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isActive ? AppColors.primary : AppColors.gray500))),
      ),
    );
  }
}