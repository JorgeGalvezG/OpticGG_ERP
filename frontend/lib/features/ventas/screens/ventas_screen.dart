import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/nueva_venta_dto.dart';
import '../models/orden_trabajo_model.dart';
import '../providers/ventas_provider.dart';
import '../providers/ordenes_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../usuarios/providers/usuarios_provider.dart';
import '../services/ticket_pdf_service.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  bool _isKanbanView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<OrdenesProvider>(
        context,
        listen: false,
      ).fetchOrdenesTablero(auth.tienda ?? 'C1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Órdenes y Ventas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gestión de flujo de laboratorio',
                    style: TextStyle(fontSize: 14, color: AppColors.gray500),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const NuevaVentaDialog(),
                ),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: Text(isMobile ? 'Nueva' : 'Nueva Venta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isMobile
              ? _buildMobileTabView()
              : (_isKanbanView
              ? _buildKanbanView()
              : const Center(child: Text("Vista de Lista"))),
        ),
      ],
    );
  }

  // --- MÉTODOS DE VISTA (KANBAN / TABS) ---
  Widget _buildKanbanView() {
    return Consumer<OrdenesProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading)
          return const Center(child: CircularProgressIndicator());
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            _buildKanbanColumn(
              'Pendientes',
              Colors.blueGrey,
              prov.pendientes,
              'LABORATORIO',
            ),
            _buildKanbanColumn(
              'En Laboratorio',
              Colors.orange,
              prov.enLaboratorio,
              'LISTO',
            ),
            _buildKanbanColumn('Listos', Colors.blue, prov.listos, 'ENTREGADO'),
            _buildKanbanColumn(
              'Entregados',
              AppColors.success,
              prov.entregados,
              null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKanbanColumn(
      String title,
      Color color,
      List<OrdenTrabajo> ordenes,
      String? siguiente,
      ) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray700,
                ),
              ),
              const Spacer(),
              Text(
                '${ordenes.length}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray400),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: ordenes.length,
              itemBuilder: (context, index) =>
                  _buildTarjetaOrden(ordenes[index], siguiente),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaOrden(OrdenTrabajo orden, String? siguienteEstado) {
    final bool tieneDeuda = orden.montoSaldo > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: tieneDeuda ? AppColors.danger : AppColors.success,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orden.numeroOrden,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, size: 18),
                      onPressed: () =>
                          TicketPdfService.imprimirTicket(orden, "C1"),
                    ),
                  ],
                ),
                Text(
                  orden.pacienteNombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo: S/ ${orden.montoSaldo.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tieneDeuda
                            ? AppColors.danger
                            : AppColors.success,
                      ),
                    ),
                    if (siguienteEstado != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: () async {
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await Provider.of<OrdenesProvider>(
                            context,
                            listen: false,
                          ).actualizarEstadoOrden(
                            orden.id,
                            siguienteEstado,
                            auth.tienda ?? 'C1',
                          );
                        },
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

  Widget _buildMobileTabView() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            tabs: [
              Tab(text: 'Pend.'),
              Tab(text: 'Lab.'),
              Tab(text: 'Listos'),
              Tab(text: 'Entreg.'),
            ],
          ),
          Expanded(
            child: Consumer<OrdenesProvider>(
              builder: (context, prov, _) => TabBarView(
                children: [
                  _buildMobileList(prov.pendientes, 'LABORATORIO'),
                  _buildMobileList(prov.enLaboratorio, 'LISTO'),
                  _buildMobileList(prov.listos, 'ENTREGADO'),
                  _buildMobileList(prov.entregados, null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<OrdenTrabajo> lista, String? siguiente) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      itemBuilder: (context, i) => _buildTarjetaOrden(lista[i], siguiente),
    );
  }
}

// =========================================================
// DIÁLOGO DE NUEVA VENTA
// =========================================================
class NuevaVentaDialog extends StatefulWidget {
  final int? pacienteIdPrecargado;
  final String? pacienteNombrePrecargado;

  const NuevaVentaDialog({
    super.key,
    this.pacienteIdPrecargado,
    this.pacienteNombrePrecargado,
  });

  @override
  State<NuevaVentaDialog> createState() => _NuevaVentaDialogState();
}

class _NuevaVentaDialogState extends State<NuevaVentaDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _monturaPropia = false;
  bool _lunasPropias = false;
  int? _vendedorId;
  String _metodoPagoSeleccionado = 'EFECTIVO'; // ← NUEVO

  // Controladores
  final _pacienteCtrl = TextEditingController();
  final _optometraCtrl = TextEditingController();
  final _odEsf = TextEditingController();
  final _odCil = TextEditingController();
  final _odEje = TextEditingController();
  final _oiEsf = TextEditingController();
  final _oiCil = TextEditingController();
  final _oiEje = TextEditingController();
  final _addCtrl = TextEditingController();
  final _dipCtrl = TextEditingController();
  final _monturaCtrl = TextEditingController();
  final _lunaCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _abonoCtrl = TextEditingController();
  String _saldo = "0.00";

  @override
  void initState() {
    super.initState();
    _totalCtrl.addListener(_calc);
    _abonoCtrl.addListener(_calc);
    if (widget.pacienteNombrePrecargado != null)
      _pacienteCtrl.text = widget.pacienteNombrePrecargado!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<UsuariosProvider>(
        context,
        listen: false,
      ).fetchActivosPorTienda(auth.tienda ?? 'C1');
    });
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _abonoCtrl.dispose();
    _pacienteCtrl.dispose();
    _optometraCtrl.dispose();
    _odEsf.dispose();
    _odCil.dispose();
    _odEje.dispose();
    _oiEsf.dispose();
    _oiCil.dispose();
    _oiEje.dispose();
    _addCtrl.dispose();
    _dipCtrl.dispose();
    _monturaCtrl.dispose();
    _lunaCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _calc() {
    double t = double.tryParse(_totalCtrl.text) ?? 0;
    double a = double.tryParse(_abonoCtrl.text) ?? 0;
    setState(() => _saldo = (t - a).toStringAsFixed(2));
  }

  String _armarMedida(String esf, String cil, String eje) {
    if (esf.isEmpty && cil.isEmpty && eje.isEmpty) return "Plano";
    return "E:${esf.isEmpty ? '0' : esf} C:${cil.isEmpty ? '0' : cil} A:${eje.isEmpty ? '0' : eje}";
  }

  void _guardarVenta() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ventasProv = Provider.of<VentasProvider>(context, listen: false);
    final ordenesProv = Provider.of<OrdenesProvider>(context, listen: false);

    final dto = NuevaVentaDTO(
      pacienteId: widget.pacienteIdPrecargado ?? 1,
      vendedorId: _vendedorId ?? 1,
      tienda: auth.tienda ?? 'C1',
      montoTotal: double.tryParse(_totalCtrl.text) ?? 0,
      montoACuenta: double.tryParse(_abonoCtrl.text) ?? 0,
      graduacionOd: _armarMedida(_odEsf.text, _odCil.text, _odEje.text),
      graduacionOi: _armarMedida(_oiEsf.text, _oiCil.text, _oiEje.text),
      esLunaCliente: _lunasPropias,
      tipoLuna: _lunasPropias ? "PROPIA" : _lunaCtrl.text,
      esMonturaCliente: _monturaPropia,
      montura: _monturaPropia ? "PROPIA" : _monturaCtrl.text,
      observaciones: _obsCtrl.text,
      metodoPago: _metodoPagoSeleccionado, // ← NUEVO: usa el estado
    );

    final exito = await ventasProv.crearNuevaVenta(dto);

    if (mounted) {
      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Venta Guardada"),
            backgroundColor: AppColors.success,
          ),
        );
        ordenesProv.fetchOrdenesTablero(auth.tienda ?? 'C1');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${ventasProv.errorMessage}"),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: isMobile ? double.infinity : 900,
        height: 800,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nueva Orden de Venta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section('1. Información General'),
                      _row(isMobile, [
                        _field(
                          'Paciente *',
                          Icons.person,
                          _pacienteCtrl,
                          req: true,
                          readOnly: widget.pacienteNombrePrecargado != null,
                        ),
                        _vendedorDropdown(),
                      ]),
                      const SizedBox(height: 24),
                      _section('2. Receta Oftálmica'),
                      _buildDataTable(),
                      const SizedBox(height: 16),
                      _row(isMobile, [
                        _field('Adición (ADD)', null, _addCtrl, hint: '+2.25'),
                        _field('D.I.P.', null, _dipCtrl, hint: '64/62'),
                      ]),
                      const SizedBox(height: 24),
                      _section('3. Detalles del Producto'),
                      _checkRow(
                        'Montura propia del cliente',
                        _monturaPropia,
                            (v) => setState(() => _monturaPropia = v!),
                      ),
                      _field(
                        'Marca/Modelo Montura',
                        Icons.wallpaper_rounded,
                        _monturaCtrl,
                        readOnly: _monturaPropia,
                      ),
                      const SizedBox(height: 12),
                      _checkRow(
                        'Lunas propias (Solo montaje)',
                        _lunasPropias,
                            (v) => setState(() => _lunasPropias = v!),
                      ),
                      _field(
                        'Tipo de Cristales',
                        Icons.remove_red_eye,
                        _lunaCtrl,
                        readOnly: _lunasPropias,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        'Observaciones Finales',
                        Icons.comment,
                        _obsCtrl,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      _section('4. Liquidación'),
                      _row(isMobile, [
                        _field(
                          'Total S/ *',
                          Icons.payments,
                          _totalCtrl,
                          num: true,
                          req: true,
                        ),
                        _field(
                          'Abono S/',
                          Icons.savings,
                          _abonoCtrl,
                          num: true,
                        ),
                        _saldoWidget(),
                      ]),
                      const SizedBox(height: 16),
                      _buildMetodosPagoRapido(isMobile),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _guardarVenta,
                  child: const Text(
                    'Confirmar Venta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODO DE PAGO RÁPIDO ← NUEVO ---
  Widget _buildMetodosPagoRapido(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Método de Pago",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, // espacio horizontal
          runSpacing: 8, // espacio vertical
          children: [
            SizedBox(
              width: isMobile ? double.infinity : 150, // Ocupa todo el ancho en móvil
              child: _botonPago('EFECTIVO', Icons.payments_rounded, Colors.green),
            ),
            SizedBox(
              width: isMobile ? double.infinity : 150,
              child: _botonPago('YAPE / PLIN', Icons.qr_code_scanner_rounded, Colors.purple),
            ),
            SizedBox(
              width: isMobile ? double.infinity : 150,
              child: _botonPago('TARJETA', Icons.credit_card_rounded, Colors.blue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _botonPago(String metodo, IconData icono, Color color) {
    final bool seleccionado = _metodoPagoSeleccionado == metodo;
    return GestureDetector(
      onTap: () => setState(() => _metodoPagoSeleccionado = metodo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seleccionado ? color : AppColors.gray200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icono,
              color: seleccionado ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              metodo,
              style: TextStyle(
                color: seleccionado ? Colors.white : Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS DE UI ---
  Widget _section(String txt) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      txt,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );

  Widget _row(bool m, List<Widget> c) => m
      ? Column(
    children: c
        .map(
          (w) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: w,
      ),
    )
        .toList(),
  )
      : Row(
    children: c
        .map(
          (w) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: w,
        ),
      ),
    )
        .toList(),
  );

  Widget _field(
      String l,
      IconData? i,
      TextEditingController c, {
        bool req = false,
        bool num = false,
        bool readOnly = false,
        String? hint,
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: c,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: num
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: i != null ? Icon(i, size: 20) : null,
        hintText: hint,
        filled: true,
        fillColor: readOnly ? AppColors.gray100 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: req ? (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        return null;
      } : null,
    );
  }

  Widget _vendedorDropdown() {
    return Consumer<UsuariosProvider>(
      builder: (context, prov, _) {
        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Vendedor *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_search),
          ),
          items: prov.usuariosActivos
              .map(
                (u) => DropdownMenuItem(
              value: u.id,
              child: Text(u.username ?? ""),
            ),
          )
              .toList(),
          onChanged: (v) => _vendedorId = v,
          validator: (v) => v == null ? 'Seleccione' : null,
        );
      },
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.primaryLight),
        columns: const [
          DataColumn(label: Text('Ojo')),
          DataColumn(label: Text('ESF')),
          DataColumn(label: Text('CIL')),
          DataColumn(label: Text('EJE')),
        ],
        rows: [
          _rowMedida('O.D.', _odEsf, _odCil, _odEje),
          _rowMedida('O.I.', _oiEsf, _oiCil, _oiEje),
        ],
      ),
    );
  }

  DataRow _rowMedida(
      String ojo,
      TextEditingController e,
      TextEditingController c,
      TextEditingController j,
      ) {
    return DataRow(
      cells: [
        DataCell(
          Text(ojo, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataCell(
          TextField(
            controller: e,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '0.00'),
          ),
        ),
        DataCell(
          TextField(
            controller: c,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '0.00'),
          ),
        ),
        DataCell(
          TextField(
            controller: j,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '0'),
          ),
        ),
      ],
    );
  }

  Widget _checkRow(String t, bool v, Function(bool?) onC) => Row(
    children: [
      Checkbox(value: v, onChanged: onC),
      Text(t, style: const TextStyle(fontSize: 13)),
    ],
  );

  Widget _saldoWidget() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.gray100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SALDO',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          'S/ $_saldo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: double.parse(_saldo) > 0
                ? AppColors.danger
                : AppColors.success,
          ),
        ),
      ],
    ),
  );
}