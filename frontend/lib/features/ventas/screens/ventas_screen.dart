import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../pacientes/models/paciente_model.dart';
import '../../pacientes/providers/pacientes_provider.dart';
import '../models/nueva_venta_dto.dart';
import '../models/orden_trabajo_model.dart';
import '../providers/ventas_provider.dart';
import '../providers/ordenes_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/config_provider.dart';
import '../../usuarios/providers/usuarios_provider.dart';
import '../services/ticket_pdf_service.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  String _filtroTexto = "";
  String _filtroEstado = "TODOS";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<OrdenesProvider>(context, listen: false).fetchOrdenesTablero(auth.tienda ?? 'C1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gestión de Órdenes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gray900)),
                      SizedBox(height: 4),
                      Text('Seguimiento y control de ventas', style: TextStyle(fontSize: 14, color: AppColors.gray500)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ── GRID DE ESTADÍSTICAS RÁPIDAS ──
              Consumer<OrdenesProvider>(
                builder: (context, prov, _) {
                  return Row(
                    children: [
                      _miniStat('PENDIENTES', prov.pendientes.length, Colors.blueGrey),
                      const SizedBox(width: 12),
                      _miniStat('LABORATORIO', prov.enLaboratorio.length, Colors.orange),
                      const SizedBox(width: 12),
                      _miniStat('LISTOS', prov.listos.length, Colors.blue),
                      const SizedBox(width: 12),
                      _miniStat('ENTREGADOS', prov.entregados.length, AppColors.success),
                    ],
                  );
                }
              ),
              const SizedBox(height: 24),
              // ── BUSCADOR Y FILTRO ──
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: (v) => setState(() => _filtroTexto = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Buscar por paciente o #orden...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _filtroEstado,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
                      ),
                      items: ['TODOS', 'PENDIENTE', 'LABORATORIO', 'LISTO', 'ENTREGADO'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) => setState(() => _filtroEstado = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _buildUnifiedListView()),
      ],
    );
  }

  Widget _miniStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.gray400)),
            const SizedBox(height: 4),
            Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedListView() {
    return Consumer<OrdenesProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) return const Center(child: CircularProgressIndicator());
        
        var todas = [...prov.pendientes, ...prov.enLaboratorio, ...prov.listos, ...prov.entregados];
        
        // APLICAR FILTROS
        if (_filtroEstado != 'TODOS') {
          todas = todas.where((o) => o.estado == _filtroEstado).toList();
        }
        if (_filtroTexto.isNotEmpty) {
          todas = todas.where((o) => 
            o.pacienteNombre.toLowerCase().contains(_filtroTexto) || 
            o.numeroOrden.toLowerCase().contains(_filtroTexto)
          ).toList();
        }

        todas.sort((a, b) => b.fecha.compareTo(a.fecha));

        if (todas.isEmpty) return const Center(child: Text('No se encontraron órdenes.'));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: todas.length,
          itemBuilder: (context, index) {
            final o = todas[index];
            return _buildOrderRow(o);
          },
        );
      },
    );
  }

  Widget _buildOrderRow(OrdenTrabajo o) {
    final bool tieneSaldo = o.montoSaldo > 0;
    final isMobile = MediaQuery.of(context).size.width < 800;

    // Helper local para formatear fecha de forma segura
    String formatearFechaUI(String fechaRaw) {
      if (fechaRaw.isEmpty) return '---';
      try {
        if (fechaRaw.contains('-') && fechaRaw.length >= 10 && fechaRaw.indexOf('-') == 2) {
          final partes = fechaRaw.split(' ')[0].split('-');
          return '${partes[0]}/${partes[1]}/${partes[2]}';
        }
        final date = DateTime.parse(fechaRaw).toLocal();
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        return fechaRaw.length >= 10 ? fechaRaw.substring(0, 10).replaceAll('-', '/') : fechaRaw;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: isMobile 
        ? Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _getStatusColor(o.estado).withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(_getStatusIcon(o.estado), color: _getStatusColor(o.estado), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(o.pacienteNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(formatearFechaUI(o.fecha), style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
                          ],
                        ),
                        Text('Orden #${o.numeroOrden}', style: const TextStyle(color: AppColors.gray500, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('S/ ${o.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(tieneSaldo ? 'Saldo: S/ ${o.montoSaldo.toStringAsFixed(2)}' : 'Pagado', 
                        style: TextStyle(color: tieneSaldo ? AppColors.danger : AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      if (tieneSaldo)
                        IconButton(
                          icon: const Icon(Icons.payments_rounded, color: Colors.green, size: 20),
                          onPressed: () => _abrirPagoSaldo(o),
                          tooltip: 'Cobrar Saldo',
                        ),
                      _buildStatusActions(o),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.print_rounded, size: 20, color: AppColors.gray400),
                        onPressed: () async {
                          final configProv = Provider.of<ConfigProvider>(context, listen: false);
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          
                          if (configProv.config == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('⚠️ Sede ${auth.tienda ?? "?"}: Datos no cargados. Conectando...'),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 2),
                            ));
                            await configProv.cargarConfig(auth.tienda ?? 'C1');
                          }

                          final config = configProv.config;
                          if (config == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('❌ Error: No se pudo conectar con el servidor para obtener datos de la óptica.'),
                              backgroundColor: AppColors.danger,
                            ));
                            return;
                          }
                          
                          try {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando ticket de impresión...'), duration: Duration(seconds: 3)));
                            await TicketPdfService.imprimirTicket(o, config);
                          } catch (e) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error al imprimir ticket: $e'),
                              backgroundColor: AppColors.danger,
                              duration: const Duration(seconds: 10),
                            ));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_rounded, size: 20, color: AppColors.primary),
                        onPressed: () async {
                          final config = Provider.of<ConfigProvider>(context, listen: false).config;
                          if (config == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Configuración de tienda no encontrada. Cargando...'), backgroundColor: Colors.orange));
                            return;
                          }
                          try {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparando archivo para compartir...'), duration: Duration(seconds: 3)));
                            await TicketPdfService.compartirOrdenWhatsApp(o, config);
                          } catch (e) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error al compartir PDF: $e'),
                              backgroundColor: AppColors.danger,
                              duration: const Duration(seconds: 10),
                            ));
                          }
                        },
                        tooltip: 'Enviar por WhatsApp',
                      ),
                    ],
                  )
                ],
              ),
            ],
          )
        : Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: _getStatusColor(o.estado).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(_getStatusIcon(o.estado), color: _getStatusColor(o.estado)),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.pacienteNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Orden #${o.numeroOrden} · ${o.fecha.length >= 10 ? o.fecha.substring(0,10) : o.fecha}', style: const TextStyle(color: AppColors.gray500, fontSize: 12)),
                    if (o.montura != null || o.tipoLuna != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${o.montura ?? "S/M"} + ${o.tipoLuna ?? "S/L"}', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('S/ ${o.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(tieneSaldo ? 'Saldo: S/ ${o.montoSaldo.toStringAsFixed(2)}' : 'Pagado', 
                      style: TextStyle(color: tieneSaldo ? AppColors.danger : AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              if (tieneSaldo)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirPagoSaldo(o),
                    icon: const Icon(Icons.payments_rounded, size: 14),
                    label: const Text('Cobrar Saldo', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      foregroundColor: Colors.green,
                      elevation: 0,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              _buildStatusActions(o),
              const SizedBox(width: 8),              IconButton(
                icon: const Icon(Icons.print_rounded, color: AppColors.gray400),
                onPressed: () async {
                  final configProv = Provider.of<ConfigProvider>(context, listen: false);
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  
                  if (configProv.config == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('⚠️ Sede ${auth.tienda ?? "?"}: Datos no cargados. Conectando...'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ));
                    await configProv.cargarConfig(auth.tienda ?? 'C1');
                  }

                  final config = configProv.config;
                  if (config == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('❌ Error: No se pudo conectar con el servidor para obtener datos de la óptica.'),
                      backgroundColor: AppColors.danger,
                    ));
                    return;
                  }
                  
                  try {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando ticket de impresión...'), duration: Duration(seconds: 3)));
                    await TicketPdfService.imprimirTicket(o, config);
                  } catch (e) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error al imprimir ticket: $e'),
                      backgroundColor: AppColors.danger,
                      duration: const Duration(seconds: 10),
                    ));
                  }
                },
                tooltip: 'Imprimir Ticket',
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, color: AppColors.primary),
                onPressed: () async {
                  final configProv = Provider.of<ConfigProvider>(context, listen: false);
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  
                  if (configProv.config == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('⚠️ Sede ${auth.tienda ?? "?"}: Datos no cargados. Conectando...'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ));
                    await configProv.cargarConfig(auth.tienda ?? 'C1');
                  }

                  final config = configProv.config;
                  if (config == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('❌ Error: No se pudo conectar con el servidor para obtener datos de la óptica.'),
                      backgroundColor: AppColors.danger,
                    ));
                    return;
                  }
                  try {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparando archivo para compartir...'), duration: Duration(seconds: 3)));
                    await TicketPdfService.compartirOrdenWhatsApp(o, config);
                  } catch (e) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error al compartir PDF: $e'),
                      backgroundColor: AppColors.danger,
                      duration: const Duration(seconds: 10),
                    ));
                  }
                },
                tooltip: 'Enviar por WhatsApp',
              ),            ],
          ),
    );
  }

  Widget _buildStatusActions(OrdenTrabajo o) {
    String label = "";
    String nextStatus = "";
    IconData icon = Icons.arrow_forward;
    
    if (o.estado == 'PENDIENTE') {
      label = "Enviar a Lab";
      nextStatus = "LABORATORIO";
      icon = Icons.science_rounded;
    } else if (o.estado == 'LABORATORIO') {
      label = "Listo";
      nextStatus = "LISTO";
      icon = Icons.check_circle_outline_rounded;
    } else if (o.estado == 'LISTO') {
      label = "Entregar";
      nextStatus = "ENTREGADO";
      icon = Icons.handshake_rounded;
      
      // SI TIENE SALDO, BLOQUEAMOS LA ENTREGA
      if (o.montoSaldo > 0) {
        return Tooltip(
          message: 'No se puede entregar si hay saldo pendiente',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.money_off_rounded, size: 14, color: AppColors.danger),
                const SizedBox(width: 4),
                Text('S/ ${o.montoSaldo.toStringAsFixed(2)} PEND.', style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            ),
          ),
        );
      }
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: const Text('ENTREGADO', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10)),
      );
    }

    return ElevatedButton.icon(
      onPressed: () async {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await Provider.of<OrdenesProvider>(context, listen: false).actualizarEstadoOrden(o.id, nextStatus, auth.tienda ?? 'C1');
      },
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    if (estado == 'PENDIENTE') return Colors.blueGrey;
    if (estado == 'LABORATORIO') return Colors.orange;
    if (estado == 'LISTO') return Colors.blue;
    if (estado == 'ENTREGADO') return AppColors.success;
    return AppColors.gray400;
  }

  IconData _getStatusIcon(String estado) {
    if (estado == 'PENDIENTE') return Icons.access_time_rounded;
    if (estado == 'LABORATORIO') return Icons.science_rounded;
    if (estado == 'LISTO') return Icons.check_circle_outline_rounded;
    if (estado == 'ENTREGADO') return Icons.handshake_rounded;
    return Icons.help_outline;
  }

  void _abrirPagoSaldo(OrdenTrabajo o) {
    final TextEditingController montoCtrl = TextEditingController(text: o.montoSaldo.toStringAsFixed(2));
    String metodoPago = 'EFECTIVO';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cobrar Saldo Pendiente', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Paciente: ${o.pacienteNombre}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto a Pagar (S/)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.payments_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text('Método de Pago', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: metodoPago,
                items: ['EFECTIVO', 'YAPE / PLIN', 'TARJETA', 'TRANSF.'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setDialogState(() => metodoPago = v!),
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                final monto = double.tryParse(montoCtrl.text) ?? 0;
                if (monto <= 0 || monto > o.montoSaldo) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monto inválido')));
                  return;
                }
                
                // Aquí llamamos al provider para registrar el pago
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final exito = await Provider.of<VentasProvider>(context, listen: false).registrarPagoSaldo(o.id, monto, metodoPago);
                
                if (exito) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    Provider.of<OrdenesProvider>(context, listen: false).fetchOrdenesTablero(auth.tienda ?? 'C1');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago registrado con éxito'), backgroundColor: AppColors.success));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${Provider.of<VentasProvider>(context, listen: false).errorMessage}'), backgroundColor: AppColors.danger));
                  }
                }
              },
              child: const Text('Confirmar Pago'),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// DIÁLOGO DE NUEVA VENTA (CON BUSCADOR DE PACIENTES)
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

  String _tipoVenta = 'ORDEN_TRABAJO'; // 'ORDEN_TRABAJO' o 'ORDEN_VENTA'
  bool _monturaPropia = false;
  bool _lunasPropias = false;
  int? _vendedorId;
  int? _pacienteId;
  String _metodoPagoSeleccionado = 'EFECTIVO';

  // Productos seleccionados (para ORDEN_VENTA)
  final List<DetalleVentaAlmacenDTO> _productosSeleccionados = [];

  // Controladores
  final _pacienteSearchCtrl = TextEditingController();
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
    
    if (widget.pacienteIdPrecargado != null) {
      _pacienteId = widget.pacienteIdPrecargado;
      _pacienteSearchCtrl.text = widget.pacienteNombrePrecargado!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<UsuariosProvider>(context, listen: false).fetchActivosPorTienda(auth.tienda ?? 'C1');
      Provider.of<PacientesProvider>(context, listen: false).fetchPacientes(auth.tienda ?? 'C1');
      // Precargar productos para el buscador
      Provider.of<com.optica.api.features.almacen.providers.AlmacenProvider>(context, listen: false).fetchProductos(auth.tienda ?? 'C1');
    });
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _abonoCtrl.dispose();
    _pacienteSearchCtrl.dispose();
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

  void _recalcularTotalDesdeProductos() {
    if (_tipoVenta == 'ORDEN_VENTA') {
      double total = 0;
      for (var p in _productosSeleccionados) {
        total += p.precioUnitario * p.cantidad;
      }
      _totalCtrl.text = total.toStringAsFixed(2);
    }
  }

  String _armarMedida(String esf, String cil, String eje) {
    if (esf.isEmpty && cil.isEmpty && eje.isEmpty) return "Plano";
    return "E:${esf.isEmpty ? '0' : esf} C:${cil.isEmpty ? '0' : cil} A:${eje.isEmpty ? '0' : eje}";
  }

  void _parsearMedida(String? medida, TextEditingController e, TextEditingController c, TextEditingController j) {
    if (medida == null || medida == "Plano" || medida.isEmpty) {
      e.text = ""; c.text = ""; j.text = "";
      return;
    }
    // Formato: E:+1.75 C:0 A:0
    try {
      final parts = medida.split(' ');
      for (var p in parts) {
        if (p.startsWith('E:')) e.text = p.substring(2);
        if (p.startsWith('C:')) c.text = p.substring(2);
        if (p.startsWith('A:')) j.text = p.substring(2);
      }
    } catch (err) {
      print("Error parseando medida: $err");
    }
  }

  void _cargarUltimaReceta() async {
    if (_pacienteId == null) return;
    
    final prov = Provider.of<PacientesProvider>(context, listen: false);
    final historial = await prov.fetchHistorialResumen(_pacienteId!);
    
    if (historial != null && mounted) {
      setState(() {
        _parsearMedida(historial.graduacionOd, _odEsf, _odCil, _odEje);
        _parsearMedida(historial.graduacionOi, _oiEsf, _oiCil, _oiEje);
        _addCtrl.text = historial.adicion ?? "";
        _dipCtrl.text = historial.dip ?? "";
        
        // También podemos cargar el material si lo desea
        if (historial.tipoLuna != null && historial.tipoLuna != "PROPIA") {
          _lunaCtrl.text = historial.tipoLuna!;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Receta cargada desde el historial"), backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se encontró historial previo para este paciente")));
    }
  }

  void _guardarVenta() async {
    if (_pacienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seleccione un paciente"), backgroundColor: AppColors.warning));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ventasProv = Provider.of<VentasProvider>(context, listen: false);
    final ordenesProv = Provider.of<OrdenesProvider>(context, listen: false);

    final dto = NuevaVentaDTO(
      pacienteId: _pacienteId!,
      vendedorId: _vendedorId ?? 1,
      tienda: auth.tienda ?? 'C1',
      tipoVenta: _tipoVenta,
      montoTotal: double.tryParse(_totalCtrl.text) ?? 0,
      montoACuenta: double.tryParse(_abonoCtrl.text) ?? 0,
      metodoPago: _metodoPagoSeleccionado,
      // Datos de fabricación
      graduacionOd: _tipoVenta == 'ORDEN_TRABAJO' ? _armarMedida(_odEsf.text, _odCil.text, _odEje.text) : null,
      graduacionOi: _tipoVenta == 'ORDEN_TRABAJO' ? _armarMedida(_oiEsf.text, _oiCil.text, _oiEje.text) : null,
      adicion: _tipoVenta == 'ORDEN_TRABAJO' ? _addCtrl.text : null,
      dip: _tipoVenta == 'ORDEN_TRABAJO' ? _dipCtrl.text : null,
      esLunaCliente: _tipoVenta == 'ORDEN_TRABAJO' ? _lunasPropias : null,
      tipoLuna: _tipoVenta == 'ORDEN_TRABAJO' ? (_lunasPropias ? "PROPIA" : _lunaCtrl.text) : null,
      esMonturaCliente: _tipoVenta == 'ORDEN_TRABAJO' ? _monturaPropia : null,
      montura: _tipoVenta == 'ORDEN_TRABAJO' ? (_monturaPropia ? "PROPIA" : _monturaCtrl.text) : null,
      observaciones: _obsCtrl.text,
      // Productos de almacén
      productos: _tipoVenta == 'ORDEN_VENTA' ? _productosSeleccionados : null,
    );

    final exito = await ventasProv.crearNuevaVenta(dto);

    if (mounted) {
      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Venta Guardada"), backgroundColor: AppColors.success));
        ordenesProv.fetchOrdenesTablero(auth.tienda ?? 'C1');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${ventasProv.errorMessage}"), backgroundColor: AppColors.danger));
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
        height: 850,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_tipoVenta == 'ORDEN_TRABAJO' ? 'Nueva Orden de Trabajo' : 'Nueva Orden de Venta', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const Text('Complete los datos para generar el comprobante', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              // SELECTOR DE TIPO DE VENTA
              Row(
                children: [
                  Expanded(
                    child: _tipoVentaButton('ORDEN_TRABAJO', 'FABRICACIÓN (Receta)', Icons.biotech_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _tipoVentaButton('ORDEN_VENTA', 'ORDEN VENTA GENERAL', Icons.inventory_2_rounded),
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section('1. Información del Cliente'),
                      _row(isMobile, [
                        _buildPacienteSearcher(),
                        _vendedorDropdown(),
                      ]),
                      const SizedBox(height: 16),
                      
                      if (_tipoVenta == 'ORDEN_TRABAJO') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _section('2. Receta Oftálmica'),
                            if (_pacienteId != null)
                              TextButton.icon(
                                onPressed: _cargarUltimaReceta,
                                icon: const Icon(Icons.history_rounded, size: 16),
                                label: const Text('Cargar Última', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                              ),
                          ],
                        ),
                        _buildDataTable(),
                        const SizedBox(height: 16),
                        _row(isMobile, [
                          _field('Adición (ADD)', null, _addCtrl, hint: '+2.25'),
                          _field('D.I.P.', null, _dipCtrl, hint: '64/62'),
                        ]),
                        const SizedBox(height: 24),
                        _section('3. Detalles del Producto'),
                        _checkRow('Montura propia del cliente', _monturaPropia, (v) => setState(() => _monturaPropia = v!)),
                        _field('Marca/Modelo Montura', Icons.wallpaper_rounded, _monturaCtrl, readOnly: _monturaPropia),
                        const SizedBox(height: 12),
                        _checkRow('Lunas propias (Solo montaje)', _lunasPropias, (v) => setState(() => _lunasPropias = v!)),
                        _field('Tipo de Cristales', Icons.remove_red_eye, _lunaCtrl, readOnly: _lunasPropias),
                      ] else ...[
                        _section('2. Productos de Almacén'),
                        _buildBuscadorProductosAlmacen(),
                        const SizedBox(height: 12),
                        _buildTablaProductosSeleccionados(),
                      ],
                      
                      const SizedBox(height: 16),
                      _field('Observaciones Finales', Icons.comment, _obsCtrl, maxLines: 2),
                      const SizedBox(height: 24),
                      _section('4. Liquidación y Pago'),
                      _row(isMobile, [
                        _field('Total S/ *', Icons.payments, _totalCtrl, num: true, req: true, readOnly: _tipoVenta == 'ORDEN_VENTA'),
                        _field('Abono S/', Icons.savings, _abonoCtrl, num: true),
                        _saldoWidget(),
                      ]),
                      const SizedBox(height: 16),
                      _buildMetodosPagoRapido(isMobile),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _guardarVenta,
                  child: const Text('Confirmar Venta y Generar Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipoVentaButton(String tipo, String label, IconData icon) {
    bool activo = _tipoVenta == tipo;
    return InkWell(
      onTap: () => setState(() => _tipoVenta = tipo),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: activo ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: activo ? AppColors.primary : AppColors.gray200, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: activo ? AppColors.primary : AppColors.gray400, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activo ? AppColors.primary : AppColors.gray500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscadorProductosAlmacen() {
    return Consumer<com.optica.api.features.almacen.providers.AlmacenProvider>(
      builder: (context, prov, _) {
        return Autocomplete<com.optica.api.features.almacen.models.almacen_model.Almacen>(
          displayStringForOption: (p) => p.nombre,
          optionsBuilder: (textValue) {
            if (textValue.text.isEmpty) return const Iterable.empty();
            return prov.productos.where((p) => 
              p.nombre.toLowerCase().contains(textValue.text.toLowerCase()) || 
              p.codigoBarras.contains(textValue.text));
          },
          onSelected: (p) {
            setState(() {
              // Buscar si ya existe
              int index = _productosSeleccionados.indexWhere((item) => item.almacenId == p.id);
              if (index != -1) {
                // Incrementar cantidad si hay stock
                _productosSeleccionados[index] = DetalleVentaAlmacenDTO(
                  almacenId: p.id,
                  cantidad: _productosSeleccionados[index].cantidad + 1,
                  precioUnitario: p.precioVenta,
                );
              } else {
                _productosSeleccionados.add(DetalleVentaAlmacenDTO(
                  almacenId: p.id,
                  cantidad: 1,
                  precioUnitario: p.precioVenta,
                ));
              }
              _recalcularTotalDesdeProductos();
            });
          },
          fieldViewBuilder: (context, ctrl, focus, onFieldSubmitted) {
            return TextField(
              controller: ctrl,
              focusNode: focus,
              decoration: InputDecoration(
                hintText: 'Escanear código o buscar producto...',
                prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.gray50,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTablaProductosSeleccionados() {
    if (_productosSeleccionados.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray200, style: BorderStyle.solid)),
        child: const Column(
          children: [
            Icon(Icons.shopping_basket_outlined, color: AppColors.gray400),
            SizedBox(height: 8),
            Text('No hay productos seleccionados', style: TextStyle(color: AppColors.gray500, fontSize: 12)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.gray200), borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _productosSeleccionados.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _productosSeleccionados[index];
          // Buscar el nombre del producto en el provider
          final prov = Provider.of<AlmacenProvider>(context, listen: false);
          final pInfo = prov.productos.firstWhere((p) => p.id == item.almacenId);

          return ListTile(
            title: Text(pInfo.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text('Precio: S/ ${item.precioUnitario.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () {
                  setState(() {
                    if (item.cantidad > 1) {
                      _productosSeleccionados[index] = DetalleVentaAlmacenDTO(almacenId: item.almacenId, cantidad: item.cantidad - 1, precioUnitario: item.precioUnitario);
                    } else {
                      _productosSeleccionados.removeAt(index);
                    }
                    _recalcularTotalDesdeProductos();
                  });
                }),
                Text('${item.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () {
                  setState(() {
                    _productosSeleccionados[index] = DetalleVentaAlmacenDTO(almacenId: item.almacenId, cantidad: item.cantidad + 1, precioUnitario: item.precioUnitario);
                    _recalcularTotalDesdeProductos();
                  });
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPacienteSearcher() {
    return Consumer<PacientesProvider>(
      builder: (context, prov, _) {
        return Autocomplete<Paciente>(
          displayStringForOption: (p) => "${p.nombre} ${p.apellidos}",
          initialValue: TextEditingValue(text: _pacienteSearchCtrl.text),
          optionsBuilder: (textValue) {
            if (textValue.text.isEmpty) return const Iterable<Paciente>.empty();
            return prov.pacientes.where((p) => 
              p.nombre.toLowerCase().contains(textValue.text.toLowerCase()) || 
              p.apellidos.toLowerCase().contains(textValue.text.toLowerCase()));
          },
          onSelected: (p) {
            _pacienteId = p.id;
            _pacienteSearchCtrl.text = "${p.nombre} ${p.apellidos}";
          },
          fieldViewBuilder: (context, ctrl, focus, onFieldSubmitted) {
            return TextFormField(
              controller: ctrl,
              focusNode: focus,
              decoration: InputDecoration(
                labelText: 'Buscar Paciente *',
                prefixIcon: const Icon(Icons.person_search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.gray50,
              ),
              validator: (v) => _pacienteId == null ? 'Seleccione un paciente' : null,
            );
          },
        );
      },
    );
  }

  Widget _buildMetodosPagoRapido(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Método de Pago", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _botonPago('EFECTIVO', Icons.payments_rounded, Colors.green),
            _botonPago('YAPE / PLIN', Icons.qr_code_scanner_rounded, Colors.purple),
            _botonPago('TARJETA', Icons.credit_card_rounded, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _botonPago(String metodo, IconData icono, Color color) {
    final bool seleccionado = _metodoPagoSeleccionado == metodo;
    return GestureDetector(
      onTap: () => setState(() => _metodoPagoSeleccionado = metodo),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: seleccionado ? color : AppColors.gray200, width: 2),
        ),
        child: Column(
          children: [
            Icon(icono, color: seleccionado ? Colors.white : color, size: 20),
            const SizedBox(height: 4),
            Text(metodo, style: TextStyle(color: seleccionado ? Colors.white : Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _section(String txt) => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(txt, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)));

  Widget _row(bool m, List<Widget> c) => m ? Column(children: c.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList()) : Row(children: c.map((w) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: w))).toList());

  Widget _field(String l, IconData? i, TextEditingController c, {bool req = false, bool num = false, bool readOnly = false, String? hint, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: num ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: l, prefixIcon: i != null ? Icon(i, size: 20) : null, hintText: hint, filled: true, fillColor: readOnly ? AppColors.gray100 : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      validator: req ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null : null,
    );
  }

  Widget _vendedorDropdown() {
    return Consumer<UsuariosProvider>(
      builder: (context, prov, _) {
        return DropdownButtonFormField<int>(
          decoration: InputDecoration(labelText: 'Vendedor *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.person_outline_rounded)),
          value: _vendedorId,
          items: prov.usuariosActivos.map((u) => DropdownMenuItem(value: u.id, child: Text(u.username ?? ""))).toList(),
          onChanged: (v) => setState(() => _vendedorId = v),
          validator: (v) => v == null ? 'Seleccione' : null,
        );
      },
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.gray200), borderRadius: BorderRadius.circular(12)),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.primaryLight.withOpacity(0.3)),
        columns: const [DataColumn(label: Text('Ojo')), DataColumn(label: Text('ESF')), DataColumn(label: Text('CIL')), DataColumn(label: Text('EJE'))],
        rows: [_rowMedida('O.D.', _odEsf, _odCil, _odEje), _rowMedida('O.I.', _oiEsf, _oiCil, _oiEje)],
      ),
    );
  }

  DataRow _rowMedida(String ojo, TextEditingController e, TextEditingController c, TextEditingController j) {
    return DataRow(cells: [DataCell(Text(ojo, style: const TextStyle(fontWeight: FontWeight.bold))), DataCell(TextField(controller: e, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: '0.00'))), DataCell(TextField(controller: c, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: '0.00'))), DataCell(TextField(controller: j, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: '0')))]);
  }

  Widget _checkRow(String t, bool v, Function(bool?) onC) => Row(children: [Checkbox(value: v, onChanged: onC), Text(t, style: const TextStyle(fontSize: 13))]);

  Widget _saldoWidget() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SALDO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        Text('S/ $_saldo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: double.parse(_saldo) > 0 ? AppColors.danger : AppColors.success)),
      ],
    ),
  );
}tStyle(fontSize: 18, fontWeight: FontWeight.bold, color: double.parse(_saldo) > 0 ? AppColors.danger : AppColors.success)),
      ],
    ),
  );
}