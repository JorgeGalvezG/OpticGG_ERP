import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../ventas/models/orden_trabajo_model.dart';
import '../../ventas/providers/ordenes_provider.dart';
import '../models/paciente_model.dart';
import '../models/paciente_reactivar_model.dart';
import '../models/paciente_con_medida_dto.dart';
import '../models/historial_paciente_dto.dart';
import '../providers/pacientes_provider.dart';
import '../../ventas/screens/ventas_screen.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  String _selectedTab = "TODOS";

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
    final tiendaActual = Provider.of<AuthProvider>(context, listen: false).tienda ?? 'C1';
    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      child: Column(
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
                : Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
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

          // 1.5 CHOICE CHIPS - SELECTOR DE VISTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todos los Pacientes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  selected: _selectedTab == "TODOS",
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: _selectedTab == "TODOS" ? Colors.white : AppColors.gray600),
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedTab = "TODOS");
                      Provider.of<PacientesProvider>(context, listen: false).fetchPacientes(tiendaActual);
                    }
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Por Reactivar (>12 meses inactivos)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  selected: _selectedTab == "REACTIVAR",
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: _selectedTab == "REACTIVAR" ? Colors.white : AppColors.gray600),
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedTab = "REACTIVAR");
                      Provider.of<PacientesProvider>(context, listen: false).fetchPacientesPorReactivar(tiendaActual);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. BUSCADOR Y FILTROS (Solo visible para la vista de Todos)
          if (_selectedTab == "TODOS") ...[
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
                        Expanded(child: _buildBotonFecha(context)),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. LISTA CONECTADA
          Consumer<PacientesProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading)
                return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
              if (provider.errorMessage.isNotEmpty)
                return Center(
                  child: Padding(padding: const EdgeInsets.all(40), child: Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: AppColors.danger),
                  )),
                );

              if (_selectedTab == "REACTIVAR") {
                if (provider.pacientesPorReactivar.isEmpty)
                  return const Center(
                    child: Padding(padding: EdgeInsets.all(40), child: Text(
                      'No hay pacientes por reactivar hoy.',
                      style: TextStyle(color: AppColors.gray500),
                    )),
                  );

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 40),
                  itemCount: provider.pacientesPorReactivar.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _PatientReactivarRow(
                    paciente: provider.pacientesPorReactivar[index],
                    isMobile: isMobile,
                  ),
                );
              }

              if (provider.pacientes.isEmpty)
                return const Center(
                  child: Padding(padding: EdgeInsets.all(40), child: Text(
                    'No hay pacientes registrados',
                    style: TextStyle(color: AppColors.gray500),
                  )),
                );

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 40),
                itemCount: provider.pacientes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _PatientRow(
                  paciente: provider.pacientes[index],
                  isMobile: isMobile,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBotonNuevo(BuildContext context, bool isMobile) {
    return ElevatedButton.icon(
      onPressed: () => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const NuevoPacienteDialog(),
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
          Provider.of<PacientesProvider>(context, listen: false)
              .filtrarPorFecha(picked);
        }
      },
      icon: const Icon(Icons.calendar_month_rounded, size: 18),
      label: const Text('Filtrar Fecha'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.gray200),
        foregroundColor: AppColors.gray700,
      ),
    );
  }
}

class _PatientRow extends StatelessWidget {
  final Paciente paciente;
  final bool isMobile;

  const _PatientRow({required this.paciente, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final bool isVip = paciente.esDestacado;
    final String phone = paciente.telefono ?? 'No registrado';
    final String lastVisit = paciente.fechaNacimiento ?? 'No registrada';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isVip
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      child: Text(
                        paciente.nombre[0].toUpperCase(),
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
                            '${paciente.nombre} ${paciente.apellidos}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isVip)
                            const Text(
                              'PACIENTE DESTACADO',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DNI / Celular:',
                          style: TextStyle(fontSize: 11, color: AppColors.gray400),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${paciente.dni ?? "S/D"} / $phone',
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
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    ElevatedButton.icon(
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
                    OutlinedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => _PacienteHistorialDialog(paciente: paciente),
                      ),
                      icon: const Icon(Icons.history_edu_rounded, size: 16),
                      label: const Text('Historial', style: TextStyle(fontSize: 12)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            _EditarPacienteDialog(paciente: paciente),
                      ),
                      icon: const Icon(Icons.edit_document, size: 16),
                      label: const Text('Editar', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  backgroundColor: isVip
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  child: Text(
                    paciente.nombre[0].toUpperCase(),
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
                        '${paciente.nombre} ${paciente.apellidos}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DNI: ${paciente.dni ?? "S/D"}  •  Celular: $phone',
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Nacimiento:',
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
                const SizedBox(width: 12),
                if (isVip)
                  const Tooltip(
                    message: 'Paciente VIP',
                    child: Icon(Icons.stars_rounded,
                        color: AppColors.warning, size: 24),
                  ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.shopping_cart_checkout_rounded,
                      color: AppColors.primary),
                  tooltip: 'Nueva Venta',
                  onPressed: () => _abrirVenta(context),
                ),
                IconButton(
                  icon: const Icon(Icons.history_edu_rounded,
                      color: AppColors.gray400),
                  tooltip: 'Ver Historial Médico',
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => _PacienteHistorialDialog(paciente: paciente),
                  ),
                ),
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

  void _abrirVenta(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NuevaVentaDialog(
        pacienteIdPrecargado: paciente.id,
        pacienteNombrePrecargado: "${paciente.nombre} ${paciente.apellidos}",
      ),
    );
  }
}

// =========================================================
// WIDGETS AUXILIARES
// =========================================================

Widget _buildFormRow(bool isMobile, List<Widget> children) {
  if (isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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

Widget _buildVipToggle({required bool value, required Function(bool) onChanged}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4),
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
class NuevoPacienteDialog extends StatefulWidget {
  const NuevoPacienteDialog({super.key});

  @override
  State<NuevoPacienteDialog> createState() => NuevoPacienteDialogState();
}

class NuevoPacienteDialogState extends State<NuevoPacienteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _edadController = TextEditingController();
  final _fechaNacController = TextEditingController();
  bool _esVip = false;

  // Nuevos controladores clínicos
  final _gradOdController = TextEditingController();
  final _avOdController = TextEditingController();
  final _gradOiController = TextEditingController();
  final _avOiController = TextEditingController();
  final _adicionController = TextEditingController();
  final _dipController = TextEditingController();
  final _tipoLunaController = TextEditingController();
  final _monturaController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _especialistaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listener para calcular edad automáticamente
    _fechaNacController.addListener(_calcularEdad);
  }

  void _calcularEdad() {
    final texto = _fechaNacController.text.trim();
    if (texto.length == 10) { // Formato YYYY-MM-DD
      try {
        final birthDate = DateTime.parse(texto);
        final today = DateTime.now();
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        if (age >= 0 && age < 120) {
          _edadController.text = age.toString();
        }
      } catch (_) {
        // Formato inválido, no hacemos nada
      }
    }
  }

  @override
  void dispose() {
    _fechaNacController.removeListener(_calcularEdad);
    _nombreController.dispose();
    _apellidosController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _edadController.dispose();
    _fechaNacController.dispose();
    
    // Disponer controladores clínicos
    _gradOdController.dispose();
    _avOdController.dispose();
    _gradOiController.dispose();
    _avOiController.dispose();
    _adicionController.dispose();
    _dipController.dispose();
    _tipoLunaController.dispose();
    _monturaController.dispose();
    _observacionesController.dispose();
    _especialistaController.dispose();
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
                          'DNI',
                          Icons.badge_rounded,
                          controller: _dniController,
                          isNumber: true,
                        ),
                        _buildTextField(
                          'Teléfono',
                          Icons.phone_android_rounded,
                          controller: _telefonoController,
                          isNumber: true,
                        ),
                      ]),
                      if (!isMobile) const SizedBox(height: 16),
                      _buildFormRow(isMobile, [
                        _buildTextField(
                          'Fecha de Nacimiento',
                          Icons.calendar_today_rounded,
                          controller: _fechaNacController,
                          hint: 'Ej: 1990-12-25',
                        ),
                        _buildTextField(
                          'Edad',
                          Icons.cake_outlined,
                          controller: _edadController,
                          isNumber: true,
                          hint: 'Ej: 32',
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildVipToggle(
                        value: _esVip,
                        onChanged: (val) => setState(() => _esVip = val),
                      ),
                      _buildClinicalSection(isMobile),
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
                          final nuevo = PacienteConMedidaDTO(
                            nombre: _nombreController.text.trim(),
                            apellidos: _apellidosController.text.trim(),
                            dni: _dniController.text.trim().isEmpty ? null : _dniController.text.trim(),
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
                            graduacionOd: _gradOdController.text.trim().isEmpty ? null : _gradOdController.text.trim(),
                            avOd: _avOdController.text.trim().isEmpty ? null : _avOdController.text.trim(),
                            graduacionOi: _gradOiController.text.trim().isEmpty ? null : _gradOiController.text.trim(),
                            avOi: _avOiController.text.trim().isEmpty ? null : _avOiController.text.trim(),
                            adicion: _adicionController.text.trim().isEmpty ? null : _adicionController.text.trim(),
                            dip: _dipController.text.trim().isEmpty ? null : _dipController.text.trim(),
                            tipoLuna: _tipoLunaController.text.trim().isEmpty ? null : _tipoLunaController.text.trim(),
                            montura: _monturaController.text.trim().isEmpty ? null : _monturaController.text.trim(),
                            observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
                            especialista: _especialistaController.text.trim().isEmpty ? null : _especialistaController.text.trim(),
                            vendedorId: null, // El backend buscará un usuario si es nulo
                          );
                          final exito = await Provider.of<PacientesProvider>(
                            context,
                            listen: false,
                          ).crearPaciente(nuevo);
                          if (!context.mounted) return;
                          if (exito != null) {
                            Navigator.pop(context, exito);
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
    int maxLines = 1,
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
          keyboardType: isNumber ? TextInputType.number : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
          maxLines: maxLines,
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

  Widget _buildClinicalSection(bool isMobile, {String? fechaActualizacion}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            const Icon(Icons.remove_red_eye_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Información Clínica (Medida)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.gray800),
            ),
          ],
        ),
        subtitle: Text(
          fechaActualizacion != null 
              ? 'Última actualización: $fechaActualizacion' 
              : 'Sin recetas previas registradas',
          style: const TextStyle(fontSize: 11, color: AppColors.gray500),
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormRow(isMobile, [
            _buildTextField(
              'Graduación OD',
              Icons.remove_red_eye_outlined,
              controller: _gradOdController,
              hint: 'Ej: ESF -1.50 CIL -0.75 x 180',
            ),
            _buildTextField(
              'AV OD',
              null,
              controller: _avOdController,
              hint: 'Ej: 20/20',
            ),
          ]),
          const SizedBox(height: 12),
          _buildFormRow(isMobile, [
            _buildTextField(
              'Graduación OI',
              Icons.remove_red_eye_outlined,
              controller: _gradOiController,
              hint: 'Ej: ESF -1.25 CIL -1.00 x 175',
            ),
            _buildTextField(
              'AV OI',
              null,
              controller: _avOiController,
              hint: 'Ej: 20/25',
            ),
          ]),
          const SizedBox(height: 12),
          _buildFormRow(isMobile, [
            _buildTextField(
              'Adición',
              Icons.add_circle_outline_rounded,
              controller: _adicionController,
              hint: 'Ej: +2.00',
            ),
            _buildTextField(
              'D.I.P.',
              Icons.straighten_rounded,
              controller: _dipController,
              hint: 'Ej: 64/62',
            ),
          ]),
          const SizedBox(height: 12),
          _buildFormRow(isMobile, [
            _buildTextField(
              'Tipo de Luna',
              Icons.science_outlined,
              controller: _tipoLunaController,
              hint: 'Ej: Resina Antireflex',
            ),
            _buildTextField(
              'Montura',
              Icons.style_rounded,
              controller: _monturaController,
              hint: 'Ej: Metal Semiaire',
            ),
          ]),
          const SizedBox(height: 12),
          _buildTextField(
            'Especialista / Optómetra',
            Icons.person_pin_rounded,
            controller: _especialistaController,
            hint: 'Ej: Dr. Fernando Cubas',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            'Observaciones Clínicas',
            Icons.edit_note_rounded,
            controller: _observacionesController,
            hint: 'Ej: Presenta cansancio visual...',
            maxLines: 2,
          ),
        ],
      ),
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
  late TextEditingController _dniController;
  late TextEditingController _telefonoController;
  late TextEditingController _edadController;
  late TextEditingController _fechaNacController;
  late bool _esVip;

  // Nuevos controladores clínicos
  late TextEditingController _gradOdController;
  late TextEditingController _avOdController;
  late TextEditingController _gradOiController;
  late TextEditingController _avOiController;
  late TextEditingController _adicionController;
  late TextEditingController _dipController;
  late TextEditingController _tipoLunaController;
  late TextEditingController _monturaController;
  late TextEditingController _observacionesController;
  late TextEditingController _especialistaController;

  HistorialPacienteDTO? _ultimoHistorial;
  bool _cargandoHistorial = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.paciente.nombre);
    _apellidosController = TextEditingController(
      text: widget.paciente.apellidos,
    );
    _dniController = TextEditingController(text: widget.paciente.dni ?? '');
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

    _gradOdController = TextEditingController();
    _avOdController = TextEditingController();
    _gradOiController = TextEditingController();
    _avOiController = TextEditingController();
    _adicionController = TextEditingController();
    _dipController = TextEditingController();
    _tipoLunaController = TextEditingController();
    _monturaController = TextEditingController();
    _observacionesController = TextEditingController();
    _especialistaController = TextEditingController();

    // Listener para calcular edad automáticamente
    _fechaNacController.addListener(_calcularEdad);

    // Cargar última receta
    _cargarUltimaReceta();
  }

  void _cargarUltimaReceta() async {
    setState(() => _cargandoHistorial = true);
    try {
      final provider = Provider.of<PacientesProvider>(context, listen: false);
      final historial = await provider.fetchHistorialResumen(widget.paciente.id!);
      if (historial != null && mounted) {
        setState(() {
          _ultimoHistorial = historial;
          _gradOdController.text = historial.graduacionOd ?? '';
          _avOdController.text = historial.avOd ?? '';
          _gradOiController.text = historial.graduacionOi ?? '';
          _avOiController.text = historial.avOi ?? '';
          _adicionController.text = historial.adicion ?? '';
          _dipController.text = historial.dip ?? '';
          _tipoLunaController.text = historial.tipoLuna ?? '';
          _monturaController.text = historial.montura ?? '';
          _observacionesController.text = historial.observaciones ?? '';
          _especialistaController.text = historial.especialista ?? '';
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _cargandoHistorial = false);
      }
    }
  }

  void _calcularEdad() {
    final texto = _fechaNacController.text.trim();
    if (texto.length == 10) { // Formato YYYY-MM-DD
      try {
        final birthDate = DateTime.parse(texto);
        final today = DateTime.now();
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        if (age >= 0 && age < 120) {
          _edadController.text = age.toString();
        }
      } catch (_) {
        // Formato inválido, no hacemos nada
      }
    }
  }

  @override
  void dispose() {
    _fechaNacController.removeListener(_calcularEdad);
    _nombreController.dispose();
    _apellidosController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _edadController.dispose();
    _fechaNacController.dispose();
    
    // Disponer controladores clínicos
    _gradOdController.dispose();
    _avOdController.dispose();
    _gradOiController.dispose();
    _avOiController.dispose();
    _adicionController.dispose();
    _dipController.dispose();
    _tipoLunaController.dispose();
    _monturaController.dispose();
    _observacionesController.dispose();
    _especialistaController.dispose();
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
                          'DNI',
                          Icons.badge_rounded,
                          controller: _dniController,
                          isNumber: true,
                        ),
                        _buildTextField(
                          'Teléfono',
                          Icons.phone_android_rounded,
                          controller: _telefonoController,
                          isNumber: true,
                        ),
                      ]),
                      if (!isMobile) const SizedBox(height: 16),
                      _buildFormRow(isMobile, [
                        _buildTextField(
                          'Fecha de Nacimiento',
                          Icons.calendar_today_rounded,
                          controller: _fechaNacController,
                          hint: 'Ej: 1990-12-25',
                        ),
                        _buildTextField(
                          'Edad',
                          Icons.cake_outlined,
                          controller: _edadController,
                          isNumber: true,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildVipToggle(
                        value: _esVip,
                        onChanged: (val) => setState(() => _esVip = val),
                      ),
                      if (_cargandoHistorial)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        _buildClinicalSection(isMobile, fechaActualizacion: _ultimoHistorial?.fechaConsulta),
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
                          final actualizado = PacienteConMedidaDTO(
                            id: widget.paciente.id,
                            nombre: _nombreController.text.trim(),
                            apellidos: _apellidosController.text.trim(),
                            dni: _dniController.text.trim().isEmpty ? null : _dniController.text.trim(),
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
                            graduacionOd: _gradOdController.text.trim().isEmpty ? null : _gradOdController.text.trim(),
                            avOd: _avOdController.text.trim().isEmpty ? null : _avOdController.text.trim(),
                            graduacionOi: _gradOiController.text.trim().isEmpty ? null : _gradOiController.text.trim(),
                            avOi: _avOiController.text.trim().isEmpty ? null : _avOiController.text.trim(),
                            adicion: _adicionController.text.trim().isEmpty ? null : _adicionController.text.trim(),
                            dip: _dipController.text.trim().isEmpty ? null : _dipController.text.trim(),
                            tipoLuna: _tipoLunaController.text.trim().isEmpty ? null : _tipoLunaController.text.trim(),
                            montura: _monturaController.text.trim().isEmpty ? null : _monturaController.text.trim(),
                            observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
                            especialista: _especialistaController.text.trim().isEmpty ? null : _especialistaController.text.trim(),
                            vendedorId: null,
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
    int maxLines = 1,
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
          keyboardType: isNumber ? TextInputType.number : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
          maxLines: maxLines,
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

  Widget _buildClinicalSection(bool isMobile, {String? fechaActualizacion}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            const Icon(Icons.remove_red_eye_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Información Clínicas (Medida)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.gray800),
            ),
          ],
        ),
        subtitle: Text(
          fechaActualizacion != null 
              ? 'Última actualización: $fechaActualizacion' 
              : 'Sin recetas previas registradas',
          style: const TextStyle(fontSize: 11, color: AppColors.gray500),
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormRow(isMobile, [
            _buildTextField(
              'Graduación OD',
              Icons.remove_red_eye_outlined,
              controller: _gradOdController,
              hint: 'Ej: ESF -1.50 CIL -0.75 x 180',
            ),
            _buildTextField(
              'AV OD',
              null,
              controller: _avOdController,
              hint: 'Ej: 20/20',
            ),
          ]),
          const SizedBox(height: 12),
          _buildFormRow(isMobile, [
            _buildTextField(
              'Graduación OI',
              Icons.remove_red_eye_outlined,
              controller: _gradOiController,
              hint: 'Ej: ESF -1.25 CIL -1.00 x 175',
            ),
            _buildTextField(
              'AV OI',
              null,
              controller: _avOiController,
              hint: 'Ej: 20/25',
            ),
          ]),
          const SizedBox(height: 12),
          _buildFormRow(isMobile, [
            _buildTextField(
              'Adición',
              Icons.add_circle_outline_rounded,
              controller: _adicionController,
              hint: 'Ej: +2.00',
            ),
            _buildTextField(
              'D.I.P.',
              Icons.straighten_rounded,
              controller: _dipController,
              hint: 'Ej: 64/62',
            ),
          ]),
          const SizedBox(height: 12),
          _buildFormRow(isMobile, [
            _buildTextField(
              'Tipo de Luna',
              Icons.science_outlined,
              controller: _tipoLunaController,
              hint: 'Ej: Resina Antireflex',
            ),
            _buildTextField(
              'Montura',
              Icons.style_rounded,
              controller: _monturaController,
              hint: 'Ej: Metal Semiaire',
            ),
          ]),
          const SizedBox(height: 12),
          _buildTextField(
            'Especialista / Optómetra',
            Icons.person_pin_rounded,
            controller: _especialistaController,
            hint: 'Ej: Dr. Fernando Cubas',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            'Observaciones Clínicas',
            Icons.edit_note_rounded,
            controller: _observacionesController,
            hint: 'Ej: Presenta cansancio visual...',
            maxLines: 2,
          ),
        ],
      ),
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
    final ordenesProv = Provider.of<OrdenesProvider>(context, listen: false);
    final lista = await ordenesProv.fetchOrdenesPorPaciente(widget.paciente.id ?? 0);

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
    final bool esVentaGeneral = o.numeroOrden.startsWith('OV-');
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la Orden
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray50.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDEN #${o.numeroOrden}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Fecha: ${o.fecha.length >= 10 ? o.fecha.substring(0, 10) : o.fecha}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.gray500,
                      ),
                    ),
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
                if (!esVentaGeneral) ...[
                  // SECCIÓN CLÍNICA (RECETA)
                  Row(
                    children: [
                      const Icon(Icons.visibility_rounded, size: 16, color: AppColors.gray400),
                      const SizedBox(width: 8),
                      Text(
                        'HISTORIAL CLÍNICO / RECETA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: AppColors.gray200.withOpacity(0.8), width: 1, borderRadius: BorderRadius.circular(8)),
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(5),
                      2: FlexColumnWidth(2.5),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: AppColors.gray50.withOpacity(0.5)),
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text('Ojo', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.gray600))),
                          Padding(padding: const EdgeInsets.all(6), child: Text('Medida / Graduación', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.gray600))),
                          Padding(padding: const EdgeInsets.all(6), child: Text('A.V.', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.gray600))),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text('OD (Derecho)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(o.graduacionOd ?? 'Plano', style: GoogleFonts.inter(fontSize: 10))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(o.avOd ?? '---', style: GoogleFonts.inter(fontSize: 10))),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text('OI (Izquierdo)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(o.graduacionOi ?? 'Plano', style: GoogleFonts.inter(fontSize: 10))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(o.avOi ?? '---', style: GoogleFonts.inter(fontSize: 10))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gray50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200.withOpacity(0.8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(color: Colors.black87, fontSize: 10),
                              children: [
                                TextSpan(text: 'Adición (ADD): ', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                TextSpan(text: o.adicion ?? '---'),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 12, color: AppColors.gray300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(color: Colors.black87, fontSize: 10),
                              children: [
                                TextSpan(text: 'D.I.P.: ', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                TextSpan(text: o.dip ?? '---'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.gray100),
                  ),
                ],
                // SECCIÓN COMERCIAL (PRODUCTOS)
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_rounded, size: 16, color: AppColors.gray400),
                    const SizedBox(width: 8),
                    Text(
                      'DETALLES DE LA COMPRA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gray50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray200.withOpacity(0.8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (esVentaGeneral)
                        _productRow('PRODUCTOS', o.tipoLuna ?? 'No registrados', false)
                      else ...[
                        _productRow('MONTURA', o.montura ?? 'No registrada', o.esMonturaCliente == true),
                        const Divider(height: 8, color: AppColors.gray100),
                        _productRow('LUNAS / CRISTALES', o.tipoLuna ?? 'No registrados', o.esLunaCliente == true),
                      ],
                      if (o.observaciones != null && o.observaciones!.isNotEmpty) ...[
                        const Divider(height: 8, color: AppColors.gray100),
                        _productRow('OBSERVACIONES', o.observaciones!, false),
                      ],
                    ],
                  ),
                ),
                if (o.tieneCompraExtra == true) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.gray100),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'COMPRA EXTRA - SEGUNDOS LENTES',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: AppColors.gray200.withOpacity(0.8), width: 1, borderRadius: BorderRadius.circular(8)),
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(5),
                      2: FlexColumnWidth(2.5),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: AppColors.gray50.withOpacity(0.5)),
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text('Ojo', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.gray600))),
                          Padding(padding: const EdgeInsets.all(6), child: Text('Medida / Graduación', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.gray600))),
                          Padding(padding: const EdgeInsets.all(6), child: Text('A.V.', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.gray600))),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text('OD (Derecho)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(o.graduacionOdExtra ?? 'Plano', style: GoogleFonts.inter(fontSize: 10))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(o.avOdExtra ?? '---', style: GoogleFonts.inter(fontSize: 10))),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text('OI (Izquierdo)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(o.graduacionOiExtra ?? 'Plano', style: GoogleFonts.inter(fontSize: 10))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(o.avOiExtra ?? '---', style: GoogleFonts.inter(fontSize: 10))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gray50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200.withOpacity(0.8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(color: Colors.black87, fontSize: 10),
                              children: [
                                TextSpan(text: 'Adición (ADD) Extra: ', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                TextSpan(text: o.adicionExtra ?? '---'),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 12, color: AppColors.gray300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(color: Colors.black87, fontSize: 10),
                              children: [
                                TextSpan(text: 'D.I.P. Extra: ', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                TextSpan(text: o.dipExtra ?? '---'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200.withOpacity(0.8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _productRow('MONTURA EXTRA', o.monturaExtra ?? 'No registrada', o.esMonturaClienteExtra == true),
                        const Divider(height: 8, color: AppColors.gray100),
                        _productRow('LUNAS EXTRA', o.tipoLunaExtra ?? 'No registradas', o.esLunaClienteExtra == true),
                        if (o.observacionesExtra != null && o.observacionesExtra!.isNotEmpty) ...[
                          const Divider(height: 8, color: AppColors.gray100),
                          _productRow('OBSERVACIONES EXTRA', o.observacionesExtra!, false),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('TOTAL INVERTIDO: ', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gray500)),
                    Text(
                      'S/ ${o.montoTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                        letterSpacing: -0.5,
                      ),
                    ),
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
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.gray400)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray800)),
      ],
    );
  }

  Widget _productRow(String label, String value, bool isClient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130, // Ancho fijo para alinear los valores verticalmente (tipo impreso)
            child: Text(
              label, 
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, 
                fontWeight: FontWeight.bold, 
                color: AppColors.gray500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value, 
                    style: GoogleFonts.inter(
                      fontSize: 11, 
                      color: AppColors.gray800,
                    ),
                  ),
                ),
                if (isClient)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.5), 
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PROPIO', 
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color c = AppColors.primary;
    if (status == 'ENTREGADO') c = AppColors.success;
    if (status == 'PENDIENTE') c = Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withOpacity(0.2))),
      child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: c)),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(fontSize: 13)),
        ],
      ),
    );
  }
}

class _PatientReactivarRow extends StatelessWidget {
  final PacienteReactivar paciente;
  final bool isMobile;

  const _PatientReactivarRow({required this.paciente, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final String phone = paciente.telefono ?? 'No registrado';
    
    String formatearFecha(String fechaRaw) {
      if (fechaRaw.isEmpty) return '---';
      try {
        final date = DateTime.parse(fechaRaw).toLocal();
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        return fechaRaw.length >= 10 ? fechaRaw.substring(0, 10).replaceAll('-', '/') : fechaRaw;
      }
    }
    
    final String fechaFormateada = formatearFecha(paciente.fechaUltimaConsulta);

    int diasInactivo = 0;
    try {
      final date = DateTime.parse(paciente.fechaUltimaConsulta);
      diasInactivo = DateTime.now().difference(date).inDays;
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        paciente.nombre[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
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
                            '${paciente.nombre} ${paciente.apellidos}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Sede: ${paciente.tienda}',
                            style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Última Consulta:',
                          style: TextStyle(fontSize: 11, color: AppColors.gray400),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fechaFormateada,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Tiempo Inactivo:',
                          style: TextStyle(fontSize: 11, color: AppColors.gray400),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$diasInactivo días',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.danger),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: phone == 'No registrado' ? null : () => _enviarMensajeReactivacion(context),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Reactivar por WhatsApp', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    paciente.nombre[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${paciente.nombre} ${paciente.apellidos}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Celular: $phone  •  Sede: ${paciente.tienda}',
                        style: const TextStyle(color: AppColors.gray500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Última Consulta:',
                        style: TextStyle(fontSize: 11, color: AppColors.gray400),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$fechaFormateada ($diasInactivo días inactivo)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: phone == 'No registrado' ? null : () => _enviarMensajeReactivacion(context),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Reactivar por WhatsApp', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
    );
  }

  void _enviarMensajeReactivacion(BuildContext context) async {
    if (paciente.telefono == null) return;
    final String cleanPhone = paciente.telefono!.replaceAll(RegExp(r'\D'), '');
    String number = cleanPhone;
    if (cleanPhone.length == 9 && cleanPhone.startsWith('9')) {
      number = '51$cleanPhone';
    }

    final String mensaje = "Estimado/a ${paciente.nombre} ${paciente.apellidos}, le saludamos de Óptica Cubas. "
        "Revisando nuestros registros, notamos que ha transcurrido más de un año desde su último control visual. "
        "Le invitamos a agendar su examen preventivo anual en nuestra sede para seguir cuidando de su salud visual. "
        "¿Le gustaría reservar una cita para esta semana?";

    final Uri url = Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(mensaje)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp. Verifique el número de teléfono.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
