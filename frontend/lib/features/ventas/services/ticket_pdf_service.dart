import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/orden_trabajo_model.dart';

/// Configuración de sucursales basada en la base de datos (config_tiendas)
class StoreConfig {
  final String name;
  final String address;
  final String phone;
  final String ruc;

  StoreConfig({required this.name, required this.address, required this.phone, required this.ruc});
}

class TicketPdfService {
  static final Map<String, StoreConfig> _tiendas = {
    'C1': StoreConfig(
      name: 'ÓPTICA CUBAS - SEDE CENTRAL',
      address: 'Av. Principal 123, Ciudad',
      phone: '987 654 321',
      ruc: '20123456789',
    ),
    'C2': StoreConfig(
      name: 'ÓPTICA CUBAS - SUCURSAL NORTE',
      address: 'Jr. Los Olivos 456',
      phone: '912 345 678',
      ruc: '20123456789',
    ),
    'C3': StoreConfig(
      name: 'ÓPTICA CUBAS - EXPRESS',
      address: 'Centro Comercial El Sol, Tda 12',
      phone: '999 888 777',
      ruc: '20123456789',
    ),
  };

  // 1. TICKET DE IMPRESIÓN (80mm)
  static Future<void> imprimirTicket(OrdenTrabajo orden, String tiendaCod) async {
    final config = _tiendas[tiendaCod] ?? _tiendas['C1']!;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 5 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(config.name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('RUC: ${config.ruc}', style: const pw.TextStyle(fontSize: 8)),
              pw.Text(config.address, style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
              pw.Text('Telf: ${config.phone}', style: const pw.TextStyle(fontSize: 7)),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),

              pw.Text('TICKET DE VENTA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('Nro: ${orden.numeroOrden}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildFilaTexto('Fecha:', orden.fecha.length >= 10 ? orden.fecha.substring(0, 10) : orden.fecha),
              _buildFilaTexto('Paciente:', orden.pacienteNombre),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('RESUMEN DE ARTÍCULOS:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 6),

              if (orden.montura != null && orden.montura!.isNotEmpty)
                _buildFilaArticulo('MONTURA:', orden.esMonturaCliente == true ? '${orden.montura} (Cliente)' : orden.montura!),
              
              if (orden.tipoLuna != null && orden.tipoLuna!.isNotEmpty)
                _buildFilaArticulo('LUNAS:', orden.esLunaCliente == true ? '${orden.tipoLuna} (Cliente)' : orden.tipoLuna!),

              if (orden.observaciones != null && orden.observaciones!.isNotEmpty)
                _buildFilaArticulo('OBSERVACIONES:', orden.observaciones!),

              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('RECETA ADJUNTA:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              ),
              pw.SizedBox(height: 4),

              if (orden.graduacionOd != null && orden.graduacionOd!.isNotEmpty)
                _buildFilaTexto('O.D.:', orden.graduacionOd!),
              
              if (orden.graduacionOi != null && orden.graduacionOi!.isNotEmpty)
                _buildFilaTexto('O.I.:', orden.graduacionOi!),

              if (orden.adicion != null && orden.adicion!.isNotEmpty)
                _buildFilaTexto('ADD:', orden.adicion!),

              if (orden.dip != null && orden.dip!.isNotEmpty)
                _buildFilaTexto('D.I.P.:', orden.dip!),

              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              _buildFilaDinero('TOTAL:', orden.montoTotal, isBold: true),
              _buildFilaDinero('A CUENTA:', orden.montoTotal - orden.montoSaldo),
              _buildFilaDinero('SALDO:', orden.montoSaldo, isBold: orden.montoSaldo > 0),

              pw.SizedBox(height: 15),
              pw.Text('¡Gracias por su confianza!', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
              pw.Text('Vuelva pronto a Óptica Cubas', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // 2. ORDEN DE COMPRA PDF (FORMATO A4/SHARE PARA WHATSAPP)
  static Future<void> compartirOrdenWhatsApp(OrdenTrabajo orden, String tiendaCod) async {
    final config = _tiendas[tiendaCod] ?? _tiendas['C1']!;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado Pro
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(config.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text('Sistema de Gestión Óptica', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('ORDEN DE COMPRA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('# ${orden.numeroOrden}', style: pw.TextStyle(fontSize: 12, color: PdfColors.red900, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2, color: PdfColors.blue900),
                pw.SizedBox(height: 20),

                // Datos del Cliente y Sede
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DATOS DEL PACIENTE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
                          pw.SizedBox(height: 4),
                          pw.Text(orden.pacienteNombre, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Fecha de Emisión: ${orden.fecha.length >= 10 ? orden.fecha.substring(0,10) : orden.fecha}'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('DATOS DE LA SEDE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
                          pw.SizedBox(height: 4),
                          pw.Text(config.address, textAlign: pw.TextAlign.right),
                          pw.Text('Telf: ${config.phone}'),
                          pw.Text('RUC: ${config.ruc}'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Receta Médica
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(color: PdfColors.blue50, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ESPECIFICACIONES TÉCNICAS (RECETA)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Expanded(child: _buildA4Info('OJO DERECHO (OD)', orden.graduacionOd ?? 'Plano')),
                          pw.Expanded(child: _buildA4Info('OJO IZQUIERDO (OI)', orden.graduacionOi ?? 'Plano')),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Detalles del Producto
                pw.Text('DETALLE DEL PEDIDO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
                pw.SizedBox(height: 8),
                _buildA4Row('MONTURA / MARCA', orden.montura ?? 'No registrada', isClient: orden.esMonturaCliente),
                _buildA4Row('TIPO DE LUNAS', orden.tipoLuna ?? 'No registradas', isClient: orden.esLunaCliente),
                if (orden.observaciones != null && orden.observaciones!.isNotEmpty)
                  _buildA4Row('OBSERVACIONES', orden.observaciones!),
                
                pw.Spacer(),

                // Resumen Financiero
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 200,
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(8)),
                      child: pw.Column(
                        children: [
                          _buildA4Dinero('TOTAL:', orden.montoTotal, isBold: true),
                          pw.Divider(),
                          _buildA4Dinero('A CUENTA:', orden.montoTotal - orden.montoSaldo),
                          _buildA4Dinero('SALDO:', orden.montoSaldo, isRed: orden.montoSaldo > 0),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Center(
                  child: pw.Text('Este documento es una orden de compra válida. Para cualquier consulta, presente su número de orden.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ),
                pw.Center(
                  child: pw.Text('¡Gracias por elegir Óptica Cubas!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Guardar y compartir
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Orden_Cubas_${orden.numeroOrden}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Hola ${orden.pacienteNombre}, aquí tienes tu orden de Óptica Cubas.');
  }

  // HELPERS
  static pw.Widget _buildFilaTexto(String etiqueta, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(etiqueta, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Flexible(child: pw.Text(valor, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }

  static pw.Widget _buildFilaArticulo(String etiqueta, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(etiqueta, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.Text(valor, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildFilaDinero(String etiqueta, double valor, {bool isBold = false}) {
    final style = pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(etiqueta, style: style),
          pw.Text('S/ ${valor.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }

  static pw.Widget _buildA4Info(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildA4Row(String label, String value, {bool? isClient}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          if (isClient == true)
            pw.Container(
              margin: const pw.EdgeInsets.only(left: 8),
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(color: PdfColors.blue100, borderRadius: pw.BorderRadius.circular(4)),
              child: pw.Text('PROPIO', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildA4Dinero(String label, double amt, {bool isBold = false, bool isRed = false}) {
    final style = pw.TextStyle(fontSize: 12, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: isRed ? PdfColors.red700 : PdfColors.black);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text('S/ ${amt.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}