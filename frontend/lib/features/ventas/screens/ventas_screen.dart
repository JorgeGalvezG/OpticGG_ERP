import 'package:flutter/cupertino.dart';
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
import '../../almacen/providers/almacen_provider.dart';
import '../../almacen/models/almacen_model.dart';

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
      Provider.of<OrdenesProvider>(context, listen: false).fetchOrdenesTablero(auth.tiendaSeleccionada);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
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
                    if (isMobile) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _miniStat('PENDIENTES', prov.pendientes.length, Colors.blueGrey, isMobile),
                            const SizedBox(width: 12),
                            _miniStat('LABORATORIO', prov.enLaboratorio.length, Colors.orange, isMobile),
                            const SizedBox(width: 12),
                            _miniStat('LISTOS', prov.listos.length, Colors.blue, isMobile),
                            const SizedBox(width: 12),
                            _miniStat('ENTREGADOS', prov.entregados.length, AppColors.success, isMobile),
                          ],
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _miniStat('PENDIENTES', prov.pendientes.length, Colors.blueGrey, isMobile),
                        _miniStat('LABORATORIO', prov.enLaboratorio.length, Colors.orange, isMobile),
                        _miniStat('LISTOS', prov.listos.length, Colors.blue, isMobile),
                        _miniStat('ENTREGADOS', prov.entregados.length, AppColors.success, isMobile),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 24),
                // ── BUSCADOR Y FILTRO ──
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: isMobile ? double.infinity : 300,
                      child: TextField(
                        onChanged: (v) => setState(() => _filtroTexto = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Buscar por paciente o #orden...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                            onPressed: () => _mostrarDialogoEscaneo(context),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gray200)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isMobile ? double.infinity : 200,
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
          _buildUnifiedListView(),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int count, Color color, bool isMobile) {
    return Container(
      width: isMobile ? 110 : 120,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
    );
  }

  Widget _buildUnifiedListView() {
    return Consumer<OrdenesProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
        
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

        if (todas.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No se encontraron órdenes.')));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (tieneSaldo)
                    IconButton(
                      icon: const Icon(Icons.payments_rounded, color: Colors.green, size: 20),
                      onPressed: () => _abrirPagoSaldo(o),
                      tooltip: 'Cobrar Saldo',
                    ),
                  _buildStatusActions(o),
                  IconButton(
                    icon: const Icon(Icons.print_rounded, size: 20, color: AppColors.gray400),
                    onPressed: () async {
                      final configProv = Provider.of<ConfigProvider>(context, listen: false);
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final targetTienda = auth.tiendaSeleccionada == 'ALL' ? (auth.tienda ?? 'C1') : auth.tiendaSeleccionada;
                      
                      if (configProv.config == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('⚠️ Sede $targetTienda: Datos no cargados. Conectando...'),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 2),
                        ));
                        await configProv.cargarConfig(targetTienda);
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
                      final configProv = Provider.of<ConfigProvider>(context, listen: false);
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final targetTienda = auth.tiendaSeleccionada == 'ALL' ? (auth.tienda ?? 'C1') : auth.tiendaSeleccionada;
                      
                      if (configProv.config == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('⚠️ Sede $targetTienda: Datos no cargados. Conectando...'),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 2),
                        ));
                        await configProv.cargarConfig(targetTienda);
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
                  ),
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
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.print_rounded, color: AppColors.gray400),
                onPressed: () async {
                  final configProv = Provider.of<ConfigProvider>(context, listen: false);
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final targetTienda = auth.tiendaSeleccionada == 'ALL' ? (auth.tienda ?? 'C1') : auth.tiendaSeleccionada;
                  
                  if (configProv.config == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('⚠️ Sede $targetTienda: Datos no cargados. Conectando...'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ));
                    await configProv.cargarConfig(targetTienda);
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
                  final targetTienda = auth.tiendaSeleccionada == 'ALL' ? (auth.tienda ?? 'C1') : auth.tiendaSeleccionada;
                  
                  if (configProv.config == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('⚠️ Sede $targetTienda: Datos no cargados. Conectando...'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ));
                    await configProv.cargarConfig(targetTienda);
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
              ),
            ],
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
        await Provider.of<OrdenesProvider>(context, listen: false).actualizarEstadoOrden(o.id, nextStatus, auth.tiendaSeleccionada);
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

  void _mostrarDialogoEscaneo(BuildContext context) {
    final TextEditingController codigoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Escanear Orden', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Posicione el escáner sobre el código de barras o escriba el código manual.', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: codigoCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Código (Ej: OT-...)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.qr_code_rounded),
              ),
              onSubmitted: (v) => _procesarBusquedaCodigo(context, v),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => _procesarBusquedaCodigo(context, codigoCtrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _procesarBusquedaCodigo(BuildContext context, String codigo) async {
    if (codigo.isEmpty) return;
    Navigator.pop(context);

    final prov = Provider.of<VentasProvider>(context, listen: false);
    final venta = await prov.buscarPorCodigo(codigo);

    if (venta != null && mounted) {
      _verDetalleVenta(venta);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontró ninguna venta con ese código'), backgroundColor: AppColors.danger));
    }
  }

  void _verDetalleVenta(Map<String, dynamic> v) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Detalle de Venta', style: TextStyle(fontWeight: FontWeight.bold)),
            _badgeEstado(v['estado']),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoDetalle('Paciente', (v['cliente']['nombre'] ?? '') + ' ' + (v['cliente']['apellidos'] ?? '')),
                _infoDetalle('Fecha', v['fecha'] ?? '---'),
                _infoDetalle('Vendedor', v['vendedor']['username'] ?? '---'),
                const Divider(height: 32),
                const Text('RESUMEN ECONÓMICO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gray500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _montoBox('TOTAL', v['montoTotal'], AppColors.primary),
                    _montoBox('A CUENTA', v['montoACuenta'], AppColors.success),
                    _montoBox('SALDO', v['montoSaldo'], AppColors.danger),
                  ],
                ),
                const Divider(height: 32),
                if (v['graduacionOd'] != null) ...[
                  const Text('RECETA Y AGUDEZA VISUAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gray500)),
                  const SizedBox(height: 8),
                  Text('O.D: ${v['graduacionOd']}   |   A.V: ${v['avOd'] ?? "-"}', style: const TextStyle(fontSize: 13)),
                  Text('O.I: ${v['graduacionOi']}   |   A.V: ${v['avOi'] ?? "-"}', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 8),
                ],
                _infoDetalle('Montura', v['montura'] ?? 'N/A'),
                _infoDetalle('Lunas', v['tipoLuna'] ?? 'N/A'),
                const SizedBox(height: 16),
                _infoDetalle('Observaciones', v['observaciones'] ?? 'Sin observaciones'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ElevatedButton.icon(
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget _infoDetalle(String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Text('$l: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Expanded(child: Text(v, style: const TextStyle(fontSize: 13)))]));

  Widget _montoBox(String l, dynamic v, Color c) => Column(children: [Text(l, style: TextStyle(fontSize: 9, color: AppColors.gray500)), Text('S/ $v', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c))]);

  Widget _badgeEstado(String? e) {
    final color = e == 'PAGADO' ? AppColors.success : AppColors.warning;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(e ?? 'PENDIENTE', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
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
                    Provider.of<OrdenesProvider>(context, listen: false).fetchOrdenesTablero(auth.tiendaSeleccionada);
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
  bool _monturaManual = false;
  bool _lunasPropias = false;
  int? _vendedorId;
  int? _pacienteId;
  String _metodoPagoSeleccionado = 'EFECTIVO';
  bool _totalManual = false;
  DateTime? _fechaVenta;
  bool _pacienteNuevoManual = false;

  // Single-eye selections
  bool _soloOD = false;
  bool _soloOI = false;
  bool _soloODExtra = false;
  bool _soloOIExtra = false;

  // Compra Extra state variables
  bool _tieneCompraExtra = false;
  bool _monturaPropiaExtra = false;
  bool _monturaManualExtra = false;
  bool _lunasPropiasExtra = false;

  String? _selectedTienda;
  final _especialistaCtrl = TextEditingController();

  // Productos seleccionados (para ORDEN_VENTA)
  final List<DetalleVentaAlmacenDTO> _productosSeleccionados = [];

  // Controladores
  final _pacienteSearchCtrl = TextEditingController();
  final _pacienteManualCtrl = TextEditingController();
  final _fechaVentaCtrl = TextEditingController();
  final _odEsf = TextEditingController();
  final _odCil = TextEditingController();
  final _odEje = TextEditingController();
  final _odAv = TextEditingController();
  final _oiEsf = TextEditingController();
  final _oiCil = TextEditingController();
  final _oiEje = TextEditingController();
  final _oiAv = TextEditingController();
  final _addCtrl = TextEditingController();
  final _dipCtrl = TextEditingController();
  final _monturaCtrl = TextEditingController();
  final _precioMonturaCtrl = TextEditingController(text: '0.00');
  final _lunaCtrl = TextEditingController();
  final _tipoLunaOdCtrl = TextEditingController();
  final _precioLunaOdCtrl = TextEditingController(text: '0.00');
  final _tipoLunaOiCtrl = TextEditingController();
  final _precioLunaOiCtrl = TextEditingController(text: '0.00');
  final _obsCtrl = TextEditingController();

  // Compra Extra Controladores
  final _odEsfExtra = TextEditingController();
  final _odCilExtra = TextEditingController();
  final _odEjeExtra = TextEditingController();
  final _odAvExtra = TextEditingController();
  final _oiEsfExtra = TextEditingController();
  final _oiCilExtra = TextEditingController();
  final _oiEjeExtra = TextEditingController();
  final _oiAvExtra = TextEditingController();
  final _addCtrlExtra = TextEditingController();
  final _dipCtrlExtra = TextEditingController();
  final _monturaCtrlExtra = TextEditingController();
  final _precioMonturaCtrlExtra = TextEditingController(text: '0.00');
  final _lunaCtrlExtra = TextEditingController();
  final _tipoLunaOdCtrlExtra = TextEditingController();
  final _precioLunaOdCtrlExtra = TextEditingController(text: '0.00');
  final _tipoLunaOiCtrlExtra = TextEditingController();
  final _precioLunaOiCtrlExtra = TextEditingController(text: '0.00');
  final _obsCtrlExtra = TextEditingController();
  final _especialistaCtrlExtra = TextEditingController();

  final _totalCtrl = TextEditingController();
  final _abonoCtrl = TextEditingController();
  String _saldo = "0.00";

  void _cargarDatosPorTienda(String tienda) {
    Provider.of<UsuariosProvider>(context, listen: false).fetchActivosPorTienda(tienda);
    Provider.of<PacientesProvider>(context, listen: false).fetchPacientes(tienda);
    Provider.of<AlmacenProvider>(context, listen: false).fetchProductos(tienda);
  }

  @override
  void initState() {
    super.initState();
    _totalCtrl.addListener(_calc);
    _abonoCtrl.addListener(_calc);
    
    // Listeners para auto-cálculo en fabricación
    _precioMonturaCtrl.addListener(_recalcularTotalFabricacion);
    _precioLunaOdCtrl.addListener(_recalcularTotalFabricacion);
    _precioLunaOiCtrl.addListener(_recalcularTotalFabricacion);

    _precioMonturaCtrlExtra.addListener(_recalcularTotalFabricacion);
    _precioLunaOdCtrlExtra.addListener(_recalcularTotalFabricacion);
    _precioLunaOiCtrlExtra.addListener(_recalcularTotalFabricacion);
    
    if (widget.pacienteIdPrecargado != null) {
      _pacienteId = widget.pacienteIdPrecargado;
      _pacienteSearchCtrl.text = widget.pacienteNombrePrecargado!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _selectedTienda = (auth.tiendaSeleccionada == 'ALL' ? 'C1' : auth.tiendaSeleccionada);
      _cargarDatosPorTienda(_selectedTienda!);
    });
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _abonoCtrl.dispose();
    _pacienteSearchCtrl.dispose();
    _pacienteManualCtrl.dispose();
    _especialistaCtrl.dispose();
    _odEsf.dispose();
    _odCil.dispose();
    _odEje.dispose();
    _odAv.dispose();
    _oiEsf.dispose();
    _oiCil.dispose();
    _oiEje.dispose();
    _oiAv.dispose();
    _addCtrl.dispose();
    _dipCtrl.dispose();
    _monturaCtrl.dispose();
    _precioMonturaCtrl.dispose();
    _lunaCtrl.dispose();
    _tipoLunaOdCtrl.dispose();
    _precioLunaOdCtrl.dispose();
    _tipoLunaOiCtrl.dispose();
    _precioLunaOiCtrl.dispose();
    _obsCtrl.dispose();

    _odEsfExtra.dispose();
    _odCilExtra.dispose();
    _odEjeExtra.dispose();
    _odAvExtra.dispose();
    _oiEsfExtra.dispose();
    _oiCilExtra.dispose();
    _oiEjeExtra.dispose();
    _oiAvExtra.dispose();
    _addCtrlExtra.dispose();
    _dipCtrlExtra.dispose();
    _monturaCtrlExtra.dispose();
    _precioMonturaCtrlExtra.dispose();
    _lunaCtrlExtra.dispose();
    _tipoLunaOdCtrlExtra.dispose();
    _precioLunaOdCtrlExtra.dispose();
    _tipoLunaOiCtrlExtra.dispose();
    _precioLunaOiCtrlExtra.dispose();
    _obsCtrlExtra.dispose();
    _especialistaCtrlExtra.dispose();

    super.dispose();
  }

  void _mostrarDialogoProductoManual() {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController priceCtrl = TextEditingController(text: '0.00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Agregar Producto Manual', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Nombre del Producto', Icons.inventory_2_rounded, nameCtrl, req: true),
            const SizedBox(height: 16),
            _field('Precio de Venta S/', Icons.sell_rounded, priceCtrl, num: true, req: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              setState(() {
                _productosSeleccionados.add(DetalleVentaAlmacenDTO(
                  nombreProductoManual: nameCtrl.text.trim(),
                  cantidad: 1,
                  precioUnitario: double.tryParse(priceCtrl.text) ?? 0.0,
                ));
                _recalcularTotalDesdeProductos();
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _calc() {
    double t = double.tryParse(_totalCtrl.text) ?? 0;
    double a = double.tryParse(_abonoCtrl.text) ?? 0;
    setState(() => _saldo = (t - a).toStringAsFixed(2));
  }

  void _recalcularTotalDesdeProductos() {
    if (_tipoVenta == 'ORDEN_VENTA' && !_totalManual) {
      double total = 0;
      for (var p in _productosSeleccionados) {
        total += p.precioUnitario * p.cantidad;
      }
      _totalCtrl.text = total.toStringAsFixed(2);
    }
  }

  void _recalcularTotalFabricacion() {
    if (_tipoVenta == 'ORDEN_TRABAJO' && !_totalManual) {
      double pM = double.tryParse(_precioMonturaCtrl.text) ?? 0;
      double pLod = double.tryParse(_precioLunaOdCtrl.text) ?? 0;
      double pLoi = double.tryParse(_precioLunaOiCtrl.text) ?? 0;
      
      double extraTotal = 0.0;
      if (_tieneCompraExtra) {
        double pMExtra = double.tryParse(_precioMonturaCtrlExtra.text) ?? 0;
        double pLodExtra = double.tryParse(_precioLunaOdCtrlExtra.text) ?? 0;
        double pLoiExtra = double.tryParse(_precioLunaOiCtrlExtra.text) ?? 0;
        extraTotal = pMExtra + pLodExtra + pLoiExtra;
      }
      
      _totalCtrl.text = (pM + pLod + pLoi + extraTotal).toStringAsFixed(2);
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
        // AV
        _odAv.text = historial.avOd ?? "";
        _oiAv.text = historial.avOi ?? "";
        
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
    if (!_pacienteNuevoManual && _pacienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seleccione un paciente o marque Paciente Nuevo"), backgroundColor: AppColors.warning));
      return;
    }
    if (_pacienteNuevoManual && _pacienteManualCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingrese el nombre del paciente"), backgroundColor: AppColors.warning));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ventasProv = Provider.of<VentasProvider>(context, listen: false);
    final ordenesProv = Provider.of<OrdenesProvider>(context, listen: false);

    final total = double.tryParse(_totalCtrl.text) ?? 0;
    double abono = double.tryParse(_abonoCtrl.text) ?? 0;
    if (_tipoVenta == 'ORDEN_VENTA' && abono == 0 && _abonoCtrl.text.trim().isEmpty) {
      abono = total;
    }

    final dto = NuevaVentaDTO(
      pacienteId: _pacienteNuevoManual ? null : _pacienteId,
      pacienteNombreManual: _pacienteNuevoManual ? _pacienteManualCtrl.text.trim() : null,
      vendedorId: _vendedorId ?? 1,
      tienda: _selectedTienda ?? auth.tienda ?? 'C1',
      tipoVenta: _tipoVenta,
      montoTotal: total,
      montoACuenta: abono,
      metodoPago: _metodoPagoSeleccionado,
      fechaManual: _fechaVenta?.toIso8601String(),
      // Datos de fabricación
      graduacionOd: _tipoVenta == 'ORDEN_TRABAJO' ? _armarMedida(_odEsf.text, _odCil.text, _odEje.text) : null,
      avOd: _tipoVenta == 'ORDEN_TRABAJO' ? _odAv.text : null,
      graduacionOi: _tipoVenta == 'ORDEN_TRABAJO' ? _armarMedida(_oiEsf.text, _oiCil.text, _oiEje.text) : null,
      avOi: _tipoVenta == 'ORDEN_TRABAJO' ? _oiAv.text : null,
      adicion: _tipoVenta == 'ORDEN_TRABAJO' ? _addCtrl.text : null,
      dip: _tipoVenta == 'ORDEN_TRABAJO' ? _dipCtrl.text : null,
      esLunaCliente: _tipoVenta == 'ORDEN_TRABAJO' ? _lunasPropias : null,
      tipoLuna: _tipoVenta == 'ORDEN_TRABAJO' ? (_lunasPropias ? "PROPIA" : _lunaCtrl.text) : null,
      tipoLunaOd: _tipoVenta == 'ORDEN_TRABAJO' && !_soloOI ? _tipoLunaOdCtrl.text : null,
      precioLunaOd: _tipoVenta == 'ORDEN_TRABAJO' && !_soloOI ? (double.tryParse(_precioLunaOdCtrl.text) ?? 0) : 0.0,
      tipoLunaOi: _tipoVenta == 'ORDEN_TRABAJO' && !_soloOD ? _tipoLunaOiCtrl.text : null,
      precioLunaOi: _tipoVenta == 'ORDEN_TRABAJO' && !_soloOD ? (double.tryParse(_precioLunaOiCtrl.text) ?? 0) : 0.0,
      esMonturaCliente: _tipoVenta == 'ORDEN_TRABAJO' ? _monturaPropia : null,
      montura: _tipoVenta == 'ORDEN_TRABAJO' ? (_monturaPropia ? "PROPIA" : _monturaCtrl.text) : null,
      precioMontura: _tipoVenta == 'ORDEN_TRABAJO' ? (double.tryParse(_precioMonturaCtrl.text) ?? 0) : null,
      observaciones: _obsCtrl.text,
      especialista: _tipoVenta == 'ORDEN_TRABAJO' ? _especialistaCtrl.text.trim() : null,

      // Compra Extra fields (Se copian las mismas medidas clínicas y especialista del primer par)
      tieneCompraExtra: _tipoVenta == 'ORDEN_TRABAJO' ? _tieneCompraExtra : null,
      graduacionOdExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _armarMedida(_odEsf.text, _odCil.text, _odEje.text) : null,
      avOdExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _odAv.text : null,
      graduacionOiExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _armarMedida(_oiEsf.text, _oiCil.text, _oiEje.text) : null,
      avOiExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _oiAv.text : null,
      adicionExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _addCtrl.text : null,
      dipExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _dipCtrl.text : null,
      esLunaClienteExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _lunasPropiasExtra : null,
      tipoLunaExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? (_lunasPropiasExtra ? "PROPIA" : _lunaCtrlExtra.text) : null,
      tipoLunaOdExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra && !_soloOIExtra ? _tipoLunaOdCtrlExtra.text : null,
      precioLunaOdExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra && !_soloOIExtra ? (double.tryParse(_precioLunaOdCtrlExtra.text) ?? 0) : 0.0,
      tipoLunaOiExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra && !_soloODExtra ? _tipoLunaOiCtrlExtra.text : null,
      precioLunaOiExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra && !_soloODExtra ? (double.tryParse(_precioLunaOiCtrlExtra.text) ?? 0) : 0.0,
      esMonturaClienteExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _monturaPropiaExtra : null,
      monturaExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? (_monturaPropiaExtra ? "PROPIA" : _monturaCtrlExtra.text) : null,
      precioMonturaExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? (double.tryParse(_precioMonturaCtrlExtra.text) ?? 0) : null,
      observacionesExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _obsCtrlExtra.text : null,
      especialistaExtra: _tipoVenta == 'ORDEN_TRABAJO' && _tieneCompraExtra ? _especialistaCtrl.text.trim() : null,

      // Productos de almacén
      productos: _tipoVenta == 'ORDEN_VENTA' ? _productosSeleccionados : null,
    );

    final exito = await ventasProv.crearNuevaVenta(dto);

    if (mounted) {
      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Venta Guardada"), backgroundColor: AppColors.success));
        ordenesProv.fetchOrdenesTablero(auth.tiendaSeleccionada);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${ventasProv.errorMessage}"), backgroundColor: AppColors.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _selectedTienda ??= (auth.tiendaSeleccionada == 'ALL' ? 'C1' : auth.tiendaSeleccionada);
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
                      if (auth.rol == 'ADMIN') ...[
                        Row(
                          children: [
                            const Text('Sede de Venta: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gray700)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(8)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedTienda,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray700),
                                  items: const [
                                    DropdownMenuItem(value: 'C1', child: Text('Sede C1')),
                                    DropdownMenuItem(value: 'C2', child: Text('Sede C2')),
                                    DropdownMenuItem(value: 'C3', child: Text('Sede C3')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedTienda = val;
                                        _vendedorId = null;
                                        _pacienteId = null;
                                        _pacienteSearchCtrl.clear();
                                        _cargarDatosPorTienda(val);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Checkbox(
                            value: _pacienteNuevoManual,
                            onChanged: (val) {
                              setState(() {
                                _pacienteNuevoManual = val ?? false;
                                if (_pacienteNuevoManual) {
                                  _pacienteId = null;
                                  _pacienteSearchCtrl.clear();
                                } else {
                                  _pacienteManualCtrl.clear();
                                }
                              });
                            },
                          ),
                          const Text('Paciente Nuevo (Ingreso Manual)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _row(isMobile, [
                        _buildPacienteSearcher(),
                        _vendedorDropdown(),
                      ]),
                      const SizedBox(height: 12),
                      _row(isMobile, [
                        _field('Fecha de Venta (Opcional)', Icons.calendar_today_rounded, _fechaVentaCtrl, readOnly: true, hint: 'Dejar vacío para hoy'),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (d != null) {
                              setState(() {
                                _fechaVenta = d;
                                _fechaVentaCtrl.text = "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
                              });
                            }
                          },
                          icon: const Icon(Icons.edit_calendar_rounded),
                          label: const Text('Cambiar Fecha'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gray200, foregroundColor: AppColors.gray900),
                        ),
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
                        // Ojo Derecho/Izquierdo filters (Determina la venta de lunas, no limita la graduación)
                        Row(
                          children: [
                            _checkRow('Solo Ojo Derecho (OD)', _soloOD, (v) => setState(() {
                              _soloOD = v!;
                              if (_soloOD) {
                                _soloOI = false;
                                _tipoLunaOiCtrl.clear(); _precioLunaOiCtrl.text = '0.00';
                              }
                              _recalcularTotalFabricacion();
                            })),
                            const SizedBox(width: 16),
                            _checkRow('Solo Ojo Izquierdo (OI)', _soloOI, (v) => setState(() {
                              _soloOI = v!;
                              if (_soloOI) {
                                _soloOD = false;
                                _tipoLunaOdCtrl.clear(); _precioLunaOdCtrl.text = '0.00';
                              }
                              _recalcularTotalFabricacion();
                            })),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDataTable(),
                        const SizedBox(height: 16),
                        _row(isMobile, [
                          _field('Adición (ADD)', null, _addCtrl, hint: '+2.25'),
                          _field('D.I.P.', null, _dipCtrl, hint: '64/62'),
                        ]),
                        const SizedBox(height: 12),
                        _field('Especialista (Quien midió al paciente) *', Icons.badge_outlined, _especialistaCtrl, req: true),
                        const SizedBox(height: 24),
                        _section('3. Detalles del Producto'),
                        _checkRow('Ingresar nombre de montura manualmente', _monturaManual, (v) => setState(() { 
                          _monturaManual = v!; 
                          if (_monturaManual) _monturaPropia = false;
                        })),
                        _checkRow('Montura propia del cliente (Solo lunas)', _monturaPropia, (v) => setState(() { 
                          _monturaPropia = v!;
                          if (_monturaPropia) _monturaManual = false;
                        })),
                        if (!_monturaManual && !_monturaPropia)
                          _buildBuscadorMonturaAlmacen(),
                        if (_monturaManual)
                          _field('Marca/Modelo de Montura', Icons.wallpaper_rounded, _monturaCtrl),
                        
                        if (!_monturaPropia)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: _field('Precio Montura S/', Icons.sell_rounded, _precioMonturaCtrl, num: true),
                          ),
                        
                        const Divider(height: 32),
                        _checkRow('Lunas propias (Solo montaje)', _lunasPropias, (v) => setState(() => _lunasPropias = v!)),
                        if (!_lunasPropias) ...[
                          const Text("Detalle de Cristales", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (!_soloOI)
                            _row(isMobile, [
                              _field('Tipo Luna O.D.', Icons.remove_red_eye, _tipoLunaOdCtrl, hint: 'Resina UV'),
                              _field('Precio O.D. S/', Icons.sell, _precioLunaOdCtrl, num: true),
                            ]),
                          if (!_soloOI && !_soloOD) const SizedBox(height: 8),
                          if (!_soloOD)
                            _row(isMobile, [
                              _field('Tipo Luna O.I.', Icons.remove_red_eye, _tipoLunaOiCtrl, hint: 'Resina UV'),
                              _field('Precio O.I. S/', Icons.sell, _precioLunaOiCtrl, num: true),
                            ]),
                        ],
                        const SizedBox(height: 12),
                        _field('Tipo de Cristales (General/Comentario)', Icons.remove_red_eye, _lunaCtrl, readOnly: _lunasPropias),

                        // Compra Extra block
                        const Divider(height: 32),
                        _checkRow('Registrar Compra Extra (Segundos Lentes)', _tieneCompraExtra, (v) => setState(() {
                          _tieneCompraExtra = v!;
                          _recalcularTotalFabricacion();
                        })),
                        if (_tieneCompraExtra) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('COMPRA EXTRA - DETALLE DE SEGUNDOS LENTES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _checkRow('Solo Ojo Derecho (OD)', _soloODExtra, (v) => setState(() {
                                      _soloODExtra = v!;
                                      if (_soloODExtra) {
                                        _soloOIExtra = false;
                                        _tipoLunaOiCtrlExtra.clear(); _precioLunaOiCtrlExtra.text = '0.00';
                                      }
                                      _recalcularTotalFabricacion();
                                    })),
                                    const SizedBox(width: 16),
                                    _checkRow('Solo Ojo Izquierdo (OI)', _soloOIExtra, (v) => setState(() {
                                      _soloOIExtra = v!;
                                      if (_soloOIExtra) {
                                        _soloODExtra = false;
                                        _tipoLunaOdCtrlExtra.clear(); _precioLunaOdCtrlExtra.text = '0.00';
                                      }
                                      _recalcularTotalFabricacion();
                                    })),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text('Detalles de Montura Extra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                _checkRow('Ingresar montura manual para compra extra', _monturaManualExtra, (v) => setState(() { 
                                  _monturaManualExtra = v!; 
                                  if (_monturaManualExtra) _monturaPropiaExtra = false;
                                })),
                                _checkRow('Montura propia del cliente (Compra extra)', _monturaPropiaExtra, (v) => setState(() { 
                                  _monturaPropiaExtra = v!;
                                  if (_monturaPropiaExtra) _monturaManualExtra = false;
                                })),
                                if (!_monturaManualExtra && !_monturaPropiaExtra)
                                  _buildBuscadorMonturaAlmacenExtra(),
                                if (_monturaManualExtra)
                                  _field('Marca/Modelo de Montura Extra', Icons.wallpaper_rounded, _monturaCtrlExtra),
                                if (!_monturaPropiaExtra)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: _field('Precio Montura Extra S/', Icons.sell_rounded, _precioMonturaCtrlExtra, num: true),
                                  ),
                                const Divider(height: 24),
                                _checkRow('Lunas propias (Compra extra)', _lunasPropiasExtra, (v) => setState(() => _lunasPropiasExtra = v!)),
                                if (!_lunasPropiasExtra) ...[
                                  const Text("Detalle de Cristales Extra", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  if (!_soloOIExtra)
                                    _row(isMobile, [
                                      _field('Tipo Luna O.D. Extra', Icons.remove_red_eye, _tipoLunaOdCtrlExtra, hint: 'Resina UV'),
                                      _field('Precio O.D. Extra S/', Icons.sell, _precioLunaOdCtrlExtra, num: true),
                                    ]),
                                  if (!_soloOIExtra && !_soloODExtra) const SizedBox(height: 8),
                                  if (!_soloODExtra)
                                    _row(isMobile, [
                                      _field('Tipo Luna O.I. Extra', Icons.remove_red_eye, _tipoLunaOiCtrlExtra, hint: 'Resina UV'),
                                      _field('Precio O.I. Extra S/', Icons.sell, _precioLunaOiCtrlExtra, num: true),
                                    ]),
                                ],
                                const SizedBox(height: 12),
                                _field('Tipo de Cristales Extra (General)', Icons.remove_red_eye, _lunaCtrlExtra, readOnly: _lunasPropiasExtra),
                                const SizedBox(height: 12),
                                _field('Observaciones Compra Extra', Icons.comment, _obsCtrlExtra, maxLines: 2),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        _section('2. Productos de Almacén'),
                        Row(
                          children: [
                            Expanded(child: _buildBuscadorProductosAlmacen()),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _mostrarDialogoProductoManual,
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Manual'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight, foregroundColor: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTablaProductosSeleccionados(),
                      ],
                      
                      const SizedBox(height: 16),
                      _field('Observaciones Finales', Icons.comment, _obsCtrl, maxLines: 2),
                      const SizedBox(height: 24),
                      _section('4. Liquidación y Pago'),
                      if (_tipoVenta == 'ORDEN_VENTA')
                        _checkRow('Ingreso manual de monto total (Desactiva auto-cálculo)', _totalManual, (v) => setState(() => _totalManual = v!)),
                      _row(isMobile, [
                        _field('Total S/ *', Icons.payments, _totalCtrl, num: true, req: true, readOnly: false), // Total is now editable for both
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
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _guardarVenta,
                    child: const Text('Confirmar Venta y Generar Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
            Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activo ? AppColors.primary : AppColors.gray500), textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscadorProductosAlmacen() {
    return Consumer<AlmacenProvider>(
      builder: (context, prov, _) {
        return Autocomplete<Almacen>(
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
          String nombreProducto = item.nombreProductoManual ?? 'Producto Manual';

          // Buscar el nombre del producto en el provider si tiene ID
          if (item.almacenId != null) {
            final prov = Provider.of<AlmacenProvider>(context, listen: false);
            try {
              final pInfo = prov.productos.firstWhere((p) => p.id == item.almacenId);
              nombreProducto = pInfo.nombre;
            } catch (e) {
              nombreProducto = 'Producto no encontrado';
            }
          }

          return ListTile(
            title: Text(nombreProducto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
    return _pacienteNuevoManual ? 
      TextFormField(
        controller: _pacienteManualCtrl,
        decoration: InputDecoration(
          labelText: 'Nombre y Apellidos del Paciente *',
          prefixIcon: const Icon(Icons.person_add_alt_1_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el nombre del paciente' : null,
      )
    : Consumer<PacientesProvider>(
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
              setState(() {
                _pacienteId = p.id;
                _pacienteSearchCtrl.text = "${p.nombre} ${p.apellidos}";
              });
            },
            fieldViewBuilder: (context, ctrl, focus, onFieldSubmitted) {
              if (ctrl.text != _pacienteSearchCtrl.text && _pacienteSearchCtrl.text.isNotEmpty) {
                ctrl.text = _pacienteSearchCtrl.text;
              }
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
    final list = [
      _botonPago('EFECTIVO', Icons.payments_rounded, Colors.green),
      _botonPago('YAPE / PLIN', Icons.qr_code_scanner_rounded, Colors.purple),
      _botonPago('TARJETA', Icons.credit_card_rounded, Colors.blue),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Método de Pago", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray700)),
        const SizedBox(height: 8),
        isMobile
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: list.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList(),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list,
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
      validator: (v) {
        if (req && (v == null || v.isEmpty)) {
          return 'Requerido';
        }
        if (num && v != null && v.isNotEmpty) {
          final val = double.tryParse(v);
          if (val == null) return 'Inválido';
          if (val < 0) return 'No negativo';
        }
        return null;
      },
    );
  }

  Widget _vendedorDropdown() {
    return Consumer<UsuariosProvider>(
      builder: (context, prov, _) {
        return DropdownButtonFormField<int>(
          decoration: InputDecoration(labelText: 'Vendedor *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.person_outline_rounded)),
          value: _vendedorId,
          items: prov.usuariosActivos.map((u) => DropdownMenuItem(value: u.id, child: Text(u.username))).toList(),
          onChanged: (v) => setState(() => _vendedorId = v),
          validator: (v) => v == null ? 'Seleccione' : null,
        );
      },
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.gray200), borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.primaryLight.withOpacity(0.3)),
          columns: const [DataColumn(label: Text('Ojo')), DataColumn(label: Text('ESF')), DataColumn(label: Text('CIL')), DataColumn(label: Text('EJE')), DataColumn(label: Text('A.V.'))],
          rows: [
            _rowMedida('O.D.', _odEsf, _odCil, _odEje, _odAv), 
            _rowMedida('O.I.', _oiEsf, _oiCil, _oiEje, _oiAv)
          ],
        ),
      ),
    );
  }

  DataRow _rowMedida(String ojo, TextEditingController e, TextEditingController c, TextEditingController j, TextEditingController av, {bool readOnly = false}) {
    return DataRow(cells: [
      DataCell(Text(ojo, style: TextStyle(fontWeight: FontWeight.bold, color: readOnly ? Colors.grey : Colors.black))), 
      DataCell(TextField(controller: e, readOnly: readOnly, textAlign: TextAlign.center, decoration: InputDecoration(hintText: '0.00', enabled: !readOnly))), 
      DataCell(TextField(controller: c, readOnly: readOnly, textAlign: TextAlign.center, decoration: InputDecoration(hintText: '0.00', enabled: !readOnly))), 
      DataCell(TextField(controller: j, readOnly: readOnly, textAlign: TextAlign.center, decoration: InputDecoration(hintText: '0', enabled: !readOnly))),
      DataCell(TextField(controller: av, readOnly: readOnly, textAlign: TextAlign.center, decoration: InputDecoration(hintText: '20/20', enabled: !readOnly))),
    ]);
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

  Widget _buildBuscadorMonturaAlmacen() {
    return Consumer<AlmacenProvider>(
      builder: (context, prov, _) => Autocomplete<Almacen>(
        displayStringForOption: (p) => p.nombre,
        optionsBuilder: (text) => text.text.isEmpty ? const Iterable.empty() : prov.productos.where((p) => (p.categoriaNombre?.toLowerCase().contains('montura') ?? false) && (p.nombre.toLowerCase().contains(text.text.toLowerCase()) || p.codigoBarras.contains(text.text))),
        onSelected: (p) {
          setState(() {
            _monturaCtrl.text = p.nombre;
            _precioMonturaCtrl.text = p.precioVenta.toStringAsFixed(2);
            _recalcularTotalFabricacion();
          });
        },
        fieldViewBuilder: (ctx, ctrl, focus, onFieldSubmitted) => TextFormField(controller: ctrl, focusNode: focus, decoration: const InputDecoration(labelText: 'Buscar Montura en Stock', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
      ),
    );
  }

  Widget _buildBuscadorMonturaAlmacenExtra() {
    return Consumer<AlmacenProvider>(
      builder: (context, prov, _) => Autocomplete<Almacen>(
        displayStringForOption: (p) => p.nombre,
        optionsBuilder: (text) => text.text.isEmpty ? const Iterable.empty() : prov.productos.where((p) => (p.categoriaNombre?.toLowerCase().contains('montura') ?? false) && (p.nombre.toLowerCase().contains(text.text.toLowerCase()) || p.codigoBarras.contains(text.text))),
        onSelected: (p) {
          setState(() {
            _monturaCtrlExtra.text = p.nombre;
            _precioMonturaCtrlExtra.text = p.precioVenta.toStringAsFixed(2);
            _recalcularTotalFabricacion();
          });
        },
        fieldViewBuilder: (ctx, ctrl, focus, onFieldSubmitted) => TextFormField(controller: ctrl, focusNode: focus, decoration: const InputDecoration(labelText: 'Buscar Montura Extra en Stock', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
      ),
    );
  }
}
