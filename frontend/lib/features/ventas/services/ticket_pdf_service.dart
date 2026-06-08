import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/orden_trabajo_model.dart';
import '../../../core/models/config_tienda_model.dart';

class TicketPdfService {
  // Helper para formatear fechas de forma segura y evitar desfases
  static String _formatearFecha(String fechaRaw) {
    if (fechaRaw.isEmpty) return '---';
    try {

      if (fechaRaw.contains('-') && fechaRaw.length >= 10 && fechaRaw.indexOf('-') == 2) {
        final partes = fechaRaw.split(' ')[0].split('-');
        return '${partes[0]}/${partes[1]}/${partes[2]}';
      }
      // Si viene en formato ISO (YYYY-MM-DD)
      final date = DateTime.parse(fechaRaw).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      // Si todo falla, devolvemos los primeros 10 caracteres
      return fechaRaw.length >= 10 ? fechaRaw.substring(0, 10).replaceAll('-', '/') : fechaRaw;
    }
  }

  // 1. TICKET DE IMPRESIÓN (80mm)
  static Future<void> imprimirTicket(OrdenTrabajo orden, ConfigTienda config) async {
    print('--- INICIANDO GENERACIÓN DE TICKET ---');
    print('📄 Orden ID: ${orden.id}, Nro: ${orden.numeroOrden}');
    print('📅 Fecha Raw: ${orden.fecha}');
    
    try {
      final pdf = pw.Document();

      // Sanitización de datos para evitar nulos accidentales en pw.Text
      final nombreOptica = config.nombreOptica.isEmpty ? "ÓPTICA" : config.nombreOptica;
      final ruc = config.ruc.isEmpty ? "---" : config.ruc;
      final direccion = config.direccion.isEmpty ? "---" : config.direccion;
      final telefono = config.telefono.isEmpty ? "---" : config.telefono;
      final fechaFormateada = _formatearFecha(orden.fecha);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginBottom: 5 * PdfPageFormat.mm,
            marginTop: 5 * PdfPageFormat.mm,
            marginLeft: 5 * PdfPageFormat.mm,
            marginRight: 5 * PdfPageFormat.mm,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(nombreOptica.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('RUC: $ruc', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(direccion, style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
                pw.Text('Telf: $telefono', style: const pw.TextStyle(fontSize: 7)),
                pw.SizedBox(height: 10),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                pw.Text('TICKET DE VENTA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text('Nro: ${orden.numeroOrden}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                _buildFilaTexto('Fecha:', fechaFormateada),
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
                pw.Text('Vuelva pronto a $nombreOptica', style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 10),
              ],
            );
          },
        ),
      );

      print(' Enviando PDF a Printing.layoutPdf...');
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
        print('💾 Guardando bytes del PDF...');
        return pdf.save();
      });
      print('[EXITOO] Proceso de impresión completado exitosamente.');
    } catch (e, stack) {
      print('[X] ERROR CRÍTICO EN TicketPdfService.imprimirTicket: $e');
      print(stack);
      rethrow;
    }
  }

  // 2. BOLETA DE VENTA PDF (FORMATO A4/SHARE PARA WHATSAPP)
  static Future<void> compartirOrdenWhatsApp(OrdenTrabajo orden, ConfigTienda config) async {
    try {
      final pdf = pw.Document();
      final fechaFormateada = _formatearFecha(orden.fecha);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(config.nombreOptica.toUpperCase(), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.Text('RUC: ${config.ruc}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                          pw.Text(config.direccion, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          pw.Text('Telf: ${config.telefono}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.blue900, width: 2),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text('BOLETA DE VENTA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                            pw.SizedBox(height: 4),
                            pw.Text('N° ${orden.numeroOrden}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 15),

                  // Datos del Paciente
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('DATOS DEL PACIENTE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [
                            pw.Expanded(child: _buildInfoLabel('NOMBRE:', orden.pacienteNombre)),
                            pw.Expanded(child: _buildInfoLabel('FECHA:', fechaFormateada)),
                          ],
                        ),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [
                            pw.Expanded(child: _buildInfoLabel('TELÉFONO:', orden.pacienteTelefono ?? '-')),
                            pw.Expanded(child: _buildInfoLabel('NUMERO DE TRABAJO:', orden.numeroOrden)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Detalle de la Venta (Tabla)
                  pw.Text('DETALLE DE PRODUCTOS Y SERVICIOS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('DESCRIPCIÓN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                      if (orden.montura != null && orden.montura!.isNotEmpty)
                        pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('MONTURA: ${orden.montura}${orden.esMonturaCliente == true ? " (CLIENTE)" : ""}')),
                            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('-', textAlign: pw.TextAlign.right)),
                          ],
                        ),
                      if (orden.tipoLuna != null && orden.tipoLuna!.isNotEmpty)
                        pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('LUNAS: ${orden.tipoLuna}${orden.esLunaCliente == true ? " (CLIENTE)" : ""}')),
                            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('-', textAlign: pw.TextAlign.right)),
                          ],
                        ),
                      pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('SERVICIO INTEGRAL ÓPTICO')),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('S/ ${orden.montoTotal.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Observaciones
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('OBSERVACIONES:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                            pw.Text(orden.observaciones ?? 'Sin observaciones adicionales.', style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 40),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          children: [
                            _buildTotalRow('TOTAL:', orden.montoTotal, isBold: true),
                            pw.SizedBox(height: 5),
                            _buildTotalRow('ABONO:', orden.montoTotal - orden.montoSaldo),
                            pw.Divider(),
                            _buildTotalRow('SALDO:', orden.montoSaldo, isRed: orden.montoSaldo > 0),
                          ],
                        ),
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  // Pie de página
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Divider(),
                        pw.SizedBox(height: 10),
                        pw.Text('¡Gracias por elegir ${config.nombreOptica}!', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text('Este documento es un comprobante de su orden. Consérvelo para el recojo de su trabajo.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                        pw.SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Compartir de forma multiplataforma (Web, Android, iOS, Windows)
      print('📤 Compartiendo PDF de forma multiplataforma...');
      await Printing.sharePdf(
        bytes: await pdf.save(), 
        filename: "Boleta_${orden.numeroOrden}_${orden.pacienteNombre.replaceAll(' ', '_')}.pdf",
      );
      
      print('✅ Proceso de compartir completado.');
    } catch (e) {
      print('❌ ERROR EN COMPARTIR: $e');
      rethrow;
    }
  }

  // HELPERS INTERNOS
  static pw.Widget _buildInfoLabel(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text('$label ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildRecetaRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, double amt, {bool isBold = false, bool isRed = false}) {
    final style = pw.TextStyle(
      fontSize: 12, 
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: isRed ? PdfColors.red700 : PdfColors.black
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text('S/ ${amt.toStringAsFixed(2)}', style: style),
      ],
    );
  }

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
}
    ),
    );
  }
}
