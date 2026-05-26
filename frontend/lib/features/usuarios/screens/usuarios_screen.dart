import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/usuario_model.dart';
import '../providers/usuarios_provider.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  @override
  void initState() {
    super.initState();
    // Apenas se abre la pantalla, le pedimos a Java TODOS los usuarios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsuariosProvider>(
        context,
        listen: false,
      ).fetchTodosLosUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Cabecera (Idéntica a la anterior)
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Personal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Registro de vendedores y asignación de tiendas',
                    style: TextStyle(fontSize: 14, color: AppColors.gray500),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const _NuevoUsuarioDialog(),
                  );
                },
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Registrar Vendedor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gray900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),

        // 2. Buscador (Idéntico a la anterior)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextField(
            onChanged: (valor) {
              Provider.of<UsuariosProvider>(
                context,
                listen: false,
              ).buscarUsuarios(valor);
            },
            decoration: InputDecoration(
              hintText: 'Buscar por nombre del personal o rol...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.gray400,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gray200),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 3. LA LISTA CONECTADA A LA BASE DE DATOS
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 24.0,
            ).copyWith(bottom: 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Consumer<UsuariosProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      'Error: ${provider.errorMessage}',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  );
                }

                final usuarios = provider.todosLosUsuarios;

                if (usuarios.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay personal registrado',
                      style: TextStyle(color: AppColors.gray500),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: usuarios.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.gray100),
                  itemBuilder: (context, index) {
                    final u = usuarios[index];
                    return _UserRow(
                      id: u.id!,
                      username: u.username,
                      rol: u.rol,
                      tienda: u.tienda,
                      activo: u.activo,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  final int id;
  final String username;
  final String rol;
  final String tienda;
  final bool activo;

  const _UserRow({
    required this.id,
    required this.username,
    required this.rol,
    required this.tienda,
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    final isVendedor = rol == 'VENDEDOR';
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isVendedor
                ? AppColors.primaryLight
                : AppColors.gray900.withOpacity(0.1),
            child: Icon(
              isVendedor
                  ? Icons.badge_rounded
                  : Icons.admin_panel_settings_rounded,
              color: isVendedor ? AppColors.primary : AppColors.gray900,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: activo ? AppColors.gray900 : AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rol,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tienda',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.gray400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tienda,
                  style: TextStyle(
                    fontSize: 13,
                    color: activo ? AppColors.gray700 : AppColors.gray400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activo ? AppColors.success : AppColors.danger,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  activo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: activo ? AppColors.success : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: activo,
            activeColor: AppColors.success,
            onChanged: (value) async {
              final exito = await Provider.of<UsuariosProvider>(
                context,
                listen: false,
              ).cambiarEstadoActivo(id);
              
              if (exito && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Estado de $username actualizado'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          // Aquí conectaremos el suspender cuenta en el futuro
        ],
      ),
    );
  }
}

// =========================================================
// FORMULARIO CONECTADO
// =========================================================
class _NuevoUsuarioDialog extends StatefulWidget {
  const _NuevoUsuarioDialog();

  @override
  State<_NuevoUsuarioDialog> createState() => _NuevoUsuarioDialogState();
}

class _NuevoUsuarioDialogState extends State<_NuevoUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();

  // ¡NUEVO! Controlador para guardar el nombre que escribas
  final _nombreController = TextEditingController();

  String _tiendaSeleccionada = 'C1';
  String _rolSeleccionado = 'VENDEDOR';

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registrar Nuevo Vendedor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Conectamos el TextField a nuestro controlador
                    _buildTextField(
                      'Nombre de Usuario',
                      Icons.person_rounded,
                      controller: _nombreController,
                      required: true,
                      hint: 'Ej: Maria Lopez',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            'Tienda Asignada',
                            Icons.storefront_rounded,
                            _tiendaSeleccionada,
                            ['C1', 'C2', 'C3'],
                            (v) => setState(() => _tiendaSeleccionada = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            'Rol',
                            Icons.badge_rounded,
                            _rolSeleccionado,
                            ['VENDEDOR', 'ADMIN'],
                            (v) => setState(() => _rolSeleccionado = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.gray200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final nuevo = Usuario(
                            username: _nombreController.text.trim(),
                            rol: _rolSeleccionado,
                            tienda: _tiendaSeleccionada,
                          );

                          // Mandamos a llamar a Java mediante el Provider
                          final exito = await Provider.of<UsuariosProvider>(
                            context,
                            listen: false,
                          ).crearUsuario(nuevo);

                          if (!context.mounted) return; // Regla de Flutter

                          if (exito) {
                            Navigator.pop(context); // Cierra el modal
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Guardado en la Base de Datos'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            final error = Provider.of<UsuariosProvider>(
                              context,
                              listen: false,
                            ).errorMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al guardar: $error'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Guardar Personal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    required TextEditingController controller,
    required bool required,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: required ? AppColors.danger : AppColors.gray600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: AppColors.gray50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
