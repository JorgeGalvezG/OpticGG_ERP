import 'package:flutter/material.dart';
import 'package:frontend/features/caja/providers/caja_provider.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/config_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/screens/main_layout.dart';
import 'features/proveedores/providers/proveedores_provider.dart';
import 'features/usuarios/providers/usuarios_provider.dart';
import 'features/pacientes/providers/pacientes_provider.dart';
import 'features/ventas/providers/ordenes_provider.dart';
import 'features/ventas/providers/ventas_provider.dart';
import 'features/almacen/providers/almacen_provider.dart';
import 'core/shared/developer_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print("🧹 Memoria SharedPreferences limpiada por completo");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => UsuariosProvider()),
        ChangeNotifierProvider(create: (_) => PacientesProvider()),
        ChangeNotifierProvider(create: (_) => VentasProvider()),
        ChangeNotifierProvider(create: (_) => OrdenesProvider()),
        ChangeNotifierProvider(create: (_) => CajaProvider()),
        ChangeNotifierProvider(create: (_) => ProveedoresProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AlmacenProvider()),
        ChangeNotifierProvider(create: (_) => DeveloperProvider()),
      ],
      child: const OpticaCubasApp(),
    ),
  );
}

class OpticaCubasApp extends StatelessWidget {
  const OpticaCubasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centro Óptico Cubas 20/20',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Segoe UI',
      ),
      home: FutureBuilder<bool>(
        // Llamamos a la función que lee la memoria del dispositivo
        future: Provider.of<AuthProvider>(context, listen: false).checkLoginStatus(),
        builder: (context, snapshot) {
          // 1. Mientras la app está "leyendo" el disco duro, mostramos carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          // 2. Una vez que terminó de leer (snapshot ya tiene datos)
          // Usamos un Consumer aquí para que, si el usuario hace Logout,
          // la app reaccione y lo mande al Login de inmediato.
          return Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return auth.isAuthenticated ? const MainLayout() : const LoginScreen();
            },
          );
        },
      ),
    );
  }
}