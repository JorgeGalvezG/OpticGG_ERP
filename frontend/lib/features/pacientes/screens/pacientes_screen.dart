import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../ventas/models/orden_trabajo_model.dart';
import '../../ventas/providers/ordenes_provider.dart';
import '../models/paciente_model.dart';
import '../providers/pacientes_provider.dart';
import '../../ventas/screens/ventas_screen.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<PacientesProvider>(
        context,
        listen: false,
      ).fetchPacientes(auth.tienda ?? 'C1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final tiendaActual =
        Provider.of<AuthProvider>(context, listen: false).tienda ?? 'C1';
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CABECERA
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Directorio de Pacientes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _buildBotonNuevo(context, isMobile),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Directorio de Pacientes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Historial clínico y registro de clientes',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    _buildBotonNuevo(context, isMobile),
                  ],
                ),
        ),

        // 2. BUSCADOR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: isMobile
              ? Column(
                  children: [
                    _buildBuscador(tiendaActual),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _buildBotonFecha(context),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 3, child: _buildBuscador(tiendaActual)),
                    const SizedBox(width: 16),
                    _buildBotonFecha(context),
                  ],
                ),
        ),
        const SizedBox(height: 24),

        // 3. LISTA CONECTADA
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 24.0,
            ).copyWith(bottom: 24.0),
            decoration: BoxDecoration(
              color: isMobile ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isMobile ? null : Border.all(color: AppColors.gray200),
            ),
            child: Consumer<PacientesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading)
                  return const Center(child: CircularProgressIndicator());
                if (provider.errorMessage.isNotEmpty)
                  return Center(
                    child: Text(
                      'Error: ${provider.errorMessage}',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  );
                if (provider.pacientes.isEmpty)
                  return const Center(
                    child: Text(
                      'No hay pacientes registrados',
                      style: TextStyle(color: AppColors.gray500),
                    ),
                  );

                return ListView.separated(
                  itemCount: provider.pacientes.length,
                  separatorBuilder: (context, index) => isMobile
                      ? const SizedBox.shrink()
                      : const Divider(height: 1, color: AppColors.gray100),
                  itemBuilder: (context, index) => _PatientRow(
                    paciente: provider.pacientes[index],
                    isMobile: isMobile,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonNuevo(BuildContext context, bool isMobile) {
    return ElevatedButton.icon(
      onPressed: () => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _NuevoPacienteDialog(),
      ),
      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
      label: Text(isMobile ? 'Nuevo' : 'Nuevo Paciente'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildBuscador(String tiendaActual) {
    return TextField(
      onChanged: (valor) => Provider.of<PacientesProvider>(
        context,
        listen: false,
      ).buscarPacientes(valor, tiendaActual),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, apellido o celular...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray400),
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
    );
  }

  Widget _buildBotonFecha(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: AppColors.gray900,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Buscando desde ${picked.start.toString().substring(0, 10)} hasta ${picked.end.toString().substring(0, 10)}',
              ),
            ),
          );
        }
      },
      icon: const Icon(
        Icons.calendar_month_rounded,
        color: AppColors.gray600,
        size: 18,
      ),
      label: const Text(
        'Filtrar Fecha',
        style: TextStyle(color: AppColors.gray700),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.gray200),
      ),
    );
  }
}

// =========================================================
// FILA DE PACIENTE — RESPONSIVA
// =========================================================
class _PatientRow extends StatelessWidget {
  final Paciente paciente;
  final bool isMobile;

  const _PatientRow({required this.paciente, required this.isMobile});

  void _abrirVenta(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NuevaVentaDialog(
        pacienteIdPrecargado: paciente.id,
        pacienteNombrePrecargado: '${paciente.nombre} ${paciente.apellidos}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = '${paciente.nombre} ${paciente.apellidos}';
    final String phone = paciente.telefono ?? 'No registrado';
    final String lastVisit = paciente.fechaNacimiento ?? 'No registrada';
    final bool isVip = paciente.esDestacado;

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isVip
                      ? AppColors.warning.withOpacity(0.15)
                      : AppColors.primaryLight,
                  child: Text(
                    name.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: isVip ? AppColors.warning : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.gray900,
                        ),
                      ),
                      if (isVip)
                        const Text(
                          'Paciente VIP',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.gray100),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Celular:',
                      style: TextStyle(fontSize: 11, color: AppColors.gray400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Nacimiento:',
                      style: TextStyle(fontSize: 11, color: AppColors.gray400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lastVisit,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirVenta(context),
                    icon: const Icon(
                      Icons.shopping_cart_checkout_rounded,
                      size: 16,
                    ),
                    label: const Text('Venta', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => _PacienteHistorialDialog(paciente: paciente),
                    ),
                    icon: const Icon(Icons.history_edu_rounded, size: 16),
                    label: const Text('Historial', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          _EditarPacienteDialog(paciente: paciente),
                    ),
                    icon: const Icon(Icons.edit_document, size: 16),
                    label: const Text('Editar', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isVip
                ? AppColors.warning.withOpacity(0.15)
                : AppColors.primaryLight,
            child: Text(
              name.substring(0, 2).toUpperCase(),
              style: TextStyle(
                color: isVip ? AppColors.warning : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.gray900,
                      ),
                    ),
                    if (isVip)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Celular: $phone',
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 13,
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
                  'F. Nacimiento / Ref:',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.gray400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lastVisit,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _PacienteHistorialDialog(paciente: paciente),
            ),
            icon: const Icon(Icons.history_edu_rounded, size: 16),
            label: const Text('Historial', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              side: const BorderSide(color: AppColors.gray300),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _abrirVenta(context),
            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 16),
            label: const Text('Generar Venta', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.edit_document, color: AppColors.gray400),
            tooltip: 'Editar/Ver Ficha',
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _EditarPacienteDialog(paciente: paciente),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// HELPER PARA FORMULARIOS RESPONSIVOS
// =========================================================
Widget _buildFormRow(bool isMobile, List<Widget> children) {
  if (isMobile) {
    return Column(
      children: children
          .map(
            (w) =>
                Padding(padding: const EdgeInsets.only(bottom: 16), child: w),
          )
          .toList(),
    );
  }
  return Row(
    children: children
        .map(
          (w) => Expanded(
            child: Padding(padding: const EdgeInsets.only(right: 16), child: w),
          ),
        )
        .toList(),
  );
}

// =========================================================
// HELPER COMPARTIDO: Toggle VIP
// =========================================================
Widget _buildVipToggle({
  required bool value,
  required void Function(bool) onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.warning.withOpacity(0.2)),
    ),
    child: SwitchListTile(
      title: const Text(
        'Marcar como Paciente VIP',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.gray700,
        ),
      ),
      subtitle: const Text(
        'Aparecerá en la lista de destacados y promociones.',
        style: TextStyle(fontSize: 12),
      ),
      secondary: const Icon(Icons.stars_rounded, color: AppColors.warning),
      value: value,
      activeColor: AppColors.warning,
      onChanged: onChanged,
    ),
  );
}

// =========================================================
// FORMULARIO: Registrar Nuevo Paciente
// =========================================================
class _NuevoPacienteDialog extends StatefulWidget {
  const _NuevoPacienteDialog();

  @override
  State<_NuevoPacienteDialog> createState() => _NuevoPacienteDialogState();
}

class _NuevoPacienteDialogState extends State<_NuevoPacienteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _edadController = TextEditingController();
  final _fechaNacController = TextEditingController();
  bool _esVip = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _edadController.dispose();
    _fechaNacController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: isMobile
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: Container(
        width: isMobile ? double.infinity : 700,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabecera
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registrar Nuevo Paciente',
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

              // Cuerpo
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormRow(isMobile, [
                        _buildTextField(
                          'Nombres',
                          Icons.person_outline_rounded,
                          controller: _nombreController,
                          required: true,
                        ),
                        _buildTextField(
                          'Apellidos',
                          null,
                          controller: _apellidosController,
                          required: true,
                        ),
                      ]),
                      if (!isMobile) const SizedBox(height: 16),
                      _buildFormRow(isMobile, [
                        _buildTextField(
                          'Teléfono',
                          Icons.phone_android_rounded,
                          controller: _telefonoController,
                          isNumber: true,
                        ),
                        _buildTextField(
                          'Edad',
                          Icons.cake_outlined,
                          controller: _edadController,
                          isNumber: true,
                          hint: 'Ej: 32',
                        ),
                      ]),
                      if (!isMobile) const SizedBox(height: 16),
                      _buildTextField(
                        'Fecha de Nacimiento',
                        Icons.calendar_today_rounded,
                        controller: _fechaNacController,
                        hint: 'Ej: 1990-12-25',
                      ),
                      const SizedBox(height: 16),
                      _buildVipToggle(
                        value: _esVip,
                        onChanged: (val) => setState(() => _esVip = val),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
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
                        backgroundColor: AppColors.primary,
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
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final nuevo = Paciente(
                            nombre: _nombreController.text.trim(),
                            apellidos: _apellidosController.text.trim(),
                            telefono: _telefonoController.text.trim().isEmpty
                                ? null
                                : _telefonoController.text.trim(),
                            edad: int.tryParse(_edadController.text.trim()),
                            fechaNacimiento:
                                _fechaNacController.text.trim().isEmpty
                                ? null
                                : _fechaNacController.text.trim(),
                            tienda: auth.tienda ?? 'C1',
                            esDestacado: _esVip,
                          );
                          final exito = await Provider.of<PacientesProvider>(
                            context,
                            listen: false,
                          ).crearPaciente(nuevo);
                          if (!context.mounted) return;
                          if (exito) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Paciente registrado'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Guardar Paciente',
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
    IconData? icon, {
    required TextEditingController controller,
    bool isNumber = false,
    bool required = false,
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
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
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
}

// =========================================================
// FORMULARIO: Editar Paciente
// =========================================================
class _EditarPacienteDialog extends StatefulWidget {
  final Paciente paciente;

  const _EditarPacienteDialog({required this.paciente});

  @override
  State<_EditarPacienteDialog> createState() => _EditarPacienteDialogState();
}

class _EditarPacienteDialogState extends State<_EditarPacienteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late TextEditingController _edadController;
  late TextEditingController _fechaNacController;
  late bool _esVip;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.paciente.nombre);
    _apellidosController = TextEditingController(
      text: widget.paciente.apellidos,
    );
    _telefonoController = TextEditingController(
      text: widget.paciente.telefono ?? '',
    );
    _edadController = TextEditingController(
      text: widget.paciente.edad?.toString() ?? '',
    );
    _fechaNacController = TextEditingController(
      text: widget.paciente.fechaNacimiento ?? '',
    );
    _esVip = widget.paciente.esDestacado;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _edadController.dispose();
    _fechaNacController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: isMobile
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: Container(
        width: isMobile ? double.infinity : 700,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabecera
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ficha de ${widget.paciente.nombre}',
                      style: const TextStyle(
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

              // Cuerpo
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormRow(isMobile, [
                        _buildTextField(
                          'Nombres',
                          Icons.person_outline_rounded,
                          controller: _nombreController,
                          required: true,
                        ),
                        _buildTextField(
                          'Apellidos',
                          null,
                          controller: _apellidosController,
                          required: true,
                        ),
                      ]),
                      if (!isMobile) const SizedBox(height: 16),
                      _buildFormRow(isMobile, [
                        _buildTextField(
                          'Teléfono',
                          Icons.phone_android_rounded,
                          controller: _telefonoController,
                          isNumber: true,
                        ),
                        _buildTextField(
                          'Edad',
                          Icons.cake_outlined,
                          controller: _edadController,
                          isNumber: true,
                        ),
                      ]),
                      if (!isMobile) const SizedBox(height: 16),
                      _buildTextField(
                        'Fecha de Nacimiento',
                        Icons.calendar_today_rounded,
                        controller: _fechaNacController,
                        hint: 'Ej: 1990-12-25',
                      ),
                      const SizedBox(height: 16),
                      _buildVipToggle(
                        value: _esVip,
                        onChanged: (val) => setState(() => _esVip = val),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
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
                      child: const Text('Cerrar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.black87,
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
                          final actualizado = Paciente(
                            id: widget.paciente.id,
                            nombre: _nombreController.text.trim(),
                            apellidos: _apellidosController.text.trim(),
                            telefono: _telefonoController.text.trim().isEmpty
                                ? null
                                : _telefonoController.text.trim(),
                            edad: int.tryParse(_edadController.text.trim()),
                            fechaNacimiento:
                                _fechaNacController.text.trim().isEmpty
                                ? null
                                : _fechaNacController.text.trim(),
                            tienda: widget.paciente.tienda,
                            esDestacado: _esVip,
                          );
                          final exito = await Provider.of<PacientesProvider>(
                            context,
                            listen: false,
                          ).actualizarPaciente(actualizado);
                          if (!context.mounted) return;
                          if (exito) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Datos actualizados'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Actualizar Datos',
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
    IconData? icon, {
    required TextEditingController controller,
    bool isNumber = false,
    bool required = false,
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
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
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
}

// =========================================================
// DIÁLOGO DE HISTORIAL (FICHA MÉDICA Y COMPRAS)
// =========================================================
class _PacienteHistorialDialog extends StatefulWidget {
  final Paciente paciente;
  const _PacienteHistorialDialog({required this.paciente});

  @override
  State<_PacienteHistorialDialog> createState() => _PacienteHistorialDialogState();
}

class _PacienteHistorialDialogState extends State<_PacienteHistorialDialog> {
  List<OrdenTrabajo> _historial = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  void _cargarHistorial() async {
    print("🔍 Cargando historial para paciente ID: ${widget.paciente.id}");
    final ordenesProv = Provider.of<OrdenesProvider>(context, listen: false);
    final lista = await ordenesProv.fetchOrdenesPorPaciente(widget.paciente.id ?? 0);
    print("📦 Órdenes encontradas para historial: ${lista.length}");
    
    if (mounted) {
      setState(() {
        _historial = lista;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: isMobile ? double.infinity : 800,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial del Paciente',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text('${widget.paciente.nombre} ${widget.paciente.apellidos}', 
                      style: const TextStyle(color: AppColors.gray500, fontSize: 14)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 32),
            
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_historial.isEmpty)
              const Expanded(child: Center(child: Text('No hay registros previos para este paciente.')))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _historial.length,
                  itemBuilder: (context, index) {
                    final o = _historial[index];
                    return _buildCardHistorial(o);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHistorial(OrdenTrabajo o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la Orden
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORDEN #${o.numeroOrden}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.primary)),
                    Text('Fecha: ${o.fecha.substring(0,10)}', style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                  ],
                ),
                _statusBadge(o.estado),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECCIÓN CLÍNICA (RECETA)
                const Row(
                  children: [
                    Icon(Icons.visibility_rounded, size: 16, color: AppColors.gray400),
                    SizedBox(width: 8),
                    Text('HISTORIAL CLÍNICO / RECETA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gray700, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _clinicalInfo('OJO DERECHO (OD)', o.graduacionOd ?? 'Plano')),
                    Container(width: 1, height: 30, color: AppColors.gray100, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    Expanded(child: _clinicalInfo('OJO IZQUIERDO (OI)', o.graduacionOi ?? 'Plano')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _clinicalInfo('ADICIÓN (ADD)', o.adicion ?? '---')),
                    Container(width: 1, height: 30, color: AppColors.gray100, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    Expanded(child: _clinicalInfo('D.I.P.', o.dip ?? '---')),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: AppColors.gray100),
                ),
                // SECCIÓN COMERCIAL (PRODUCTOS)
                const Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded, size: 16, color: AppColors.gray400),
                    SizedBox(width: 8),
                    Text('DETALLES DE LA COMPRA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gray700, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 12),
                _productRow('MONTURA', o.montura ?? 'No registrada', o.esMonturaCliente == true),
                const SizedBox(height: 8),
                _productRow('LUNAS / CRISTALES', o.tipoLuna ?? 'No registrados', o.esLunaCliente == true),
                if (o.observaciones != null && o.observaciones!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _productRow('OBSERVACIONES', o.observaciones!, false),
                  ),
                const SizedBox(height: 16),
                // TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('TOTAL INVERTIDO: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gray500)),
                    Text('S/ ${o.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.gray900)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _clinicalInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.gray400)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray800)),
      ],
    );
  }

  Widget _productRow(String label, String value, bool isClient) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gray600)),
        Text(value, style: const TextStyle(fontSize: 11, color: AppColors.gray800)),
        if (isClient)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(4)),
            child: const Text('PROPIO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color c = AppColors.primary;
    if (status == 'ENTREGADO') c = AppColors.success;
    if (status == 'PENDIENTE') c = Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withOpacity(0.2))),
      child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: c)),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
