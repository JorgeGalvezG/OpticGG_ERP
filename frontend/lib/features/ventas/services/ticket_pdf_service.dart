import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/orden_trabajo_model.dart';
import '../../../core/models/config_tienda_model.dart';

class TicketPdfService {
  static String _formatearFecha(String fechaRaw) {
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

  static Future<void> imprimirTicket(OrdenTrabajo orden, ConfigTienda config) async {
    try {
      final pdf = pw.Document();
      final nombreOptica = config.nombreOptica.isEmpty ? "ÓPTICA" : config.nombreOptica;
      final ruc = config.ruc.isEmpty ? "---" : config.ruc;
      final direccion = config.direccion.isEmpty ? "---" : config.direccion;
      final telefono = config.telefono.isEmpty ? "---" : config.telefono;
      final fechaFormateada = _formatearFecha(orden.fecha);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80.copyWith(marginBottom: 5 * PdfPageFormat.mm, marginTop: 5 * PdfPageFormat.mm, marginLeft: 5 * PdfPageFormat.mm, marginRight: 5 * PdfPageFormat.mm),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(nombreOptica.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('RUC: $ruc', style: pw.TextStyle(fontSize: 8)),
                pw.Text(direccion, style: pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
                pw.Text('Telf: $telefono', style: pw.TextStyle(fontSize: 7)),
                pw.SizedBox(height: 10),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),
                pw.FittedBox(fit: pw.BoxFit.scaleDown, child: pw.Text('TICKET DE VENTA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                pw.FittedBox(fit: pw.BoxFit.scaleDown, child: pw.Text('Nro: ${orden.numeroOrden}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 8),
                _buildFilaTexto('Fecha:', fechaFormateada),
                _buildFilaTexto('Paciente:', orden.pacienteNombre),
                pw.SizedBox(height: 10),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 8),
                pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('RESUMEN DE ARTÍCULOS:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 8),

                // Caja Montura 80mm
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('MONTURA:', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        (orden.montura != null && orden.montura!.isNotEmpty) 
                          ? '${orden.montura!.toUpperCase()}${orden.esMonturaCliente == true ? " (PROPIA)" : ""}'
                          : '---',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),

                // Caja Cristales 80mm
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PRODUCTOS / CRISTALES:', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        (orden.tipoLuna != null && orden.tipoLuna!.isNotEmpty)
                          ? '${orden.tipoLuna!.toUpperCase()}${orden.esLunaCliente == true ? " (PROPIO)" : ""}'
                          : 'SERVICIO ÓPTICO INTEGRAL',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)
                      ),
                    ],
                  ),
                ),

                if (orden.observaciones != null && orden.observaciones!.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('OBSERVACIONES:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                  pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text(orden.observaciones!, style: pw.TextStyle(fontSize: 8))),
                ],

                pw.SizedBox(height: 10),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 8),
                _buildFilaDinero('TOTAL:', orden.montoTotal, isBold: true),
                _buildFilaDinero('A CUENTA:', orden.montoTotal - orden.montoSaldo),
                _buildFilaDinero('SALDO:', orden.montoSaldo, isBold: orden.montoSaldo > 0),
                pw.SizedBox(height: 15),
                pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: orden.numeroOrden, width: 65, height: 65),
                pw.SizedBox(height: 10),
                pw.Text('¡Gracias por su confianza!', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                pw.Text('Vuelva pronto a $nombreOptica', style: pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 10),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> compartirOrdenWhatsApp(OrdenTrabajo orden, ConfigTienda config) async {
    try {
      final pdf = pw.Document();
      final fechaFormateada = _formatearFecha(orden.fecha);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(25), 
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(config.nombreOptica.toUpperCase(), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 4),
                          pw.Text('RUC: ${config.ruc}', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
                          pw.Text(config.direccion, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                          pw.Text('Teléfono: ${config.telefono}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 2), borderRadius: pw.BorderRadius.circular(10)),
                        child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text('BOLETA DE VENTA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900), textAlign: pw.TextAlign.center),
                            pw.SizedBox(height: 6),
                            pw.FittedBox(fit: pw.BoxFit.scaleDown, child: pw.Text('N° ${orden.numeroOrden}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red900))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                pw.SizedBox(height: 15),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(color: PdfColors.blue50, borderRadius: pw.BorderRadius.circular(10), border: pw.Border.all(color: PdfColors.blue200)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INFORMACIÓN DEL PACIENTE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Expanded(child: _buildInfoLabel('PACIENTE:', orden.pacienteNombre.toUpperCase())),
                          pw.Expanded(child: _buildInfoLabel('FECHA:', fechaFormateada)),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        children: [
                          pw.Expanded(child: _buildInfoLabel('TELÉFONO:', orden.pacienteTelefono ?? '-')),
                          pw.Expanded(child: _buildInfoLabel('N° ORDEN:', orden.numeroOrden)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 25),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(15),
                        decoration: pw.BoxDecoration(color: PdfColors.white, border: pw.Border.all(color: PdfColors.blue900, width: 1), borderRadius: pw.BorderRadius.circular(12)),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: pw.BoxDecoration(color: PdfColors.blue900, borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))), child: pw.Text('MONTURA', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                            pw.SizedBox(height: 12),
                            pw.Text((orden.montura != null && orden.montura!.isNotEmpty) ? orden.montura!.toUpperCase() : 'SIN MONTURA', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            if (orden.esMonturaCliente == true) pw.Text('(PROPIA DEL CLIENTE)', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic)),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(15),
                        decoration: pw.BoxDecoration(color: PdfColors.white, border: pw.Border.all(color: PdfColors.blue900, width: 1), borderRadius: pw.BorderRadius.circular(12)),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: pw.BoxDecoration(color: PdfColors.blue900, borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))), child: pw.Text('PRODUCTOS / CRISTALES', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                            pw.SizedBox(height: 12),
                            pw.Text((orden.tipoLuna != null && orden.tipoLuna!.isNotEmpty) ? orden.tipoLuna!.toUpperCase() : 'SERVICIO ÓPTICO INTEGRAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            if (orden.esLunaCliente == true) pw.Text('(PROPIAS DEL CLIENTE)', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('OBSERVACIONES:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 6),
                          pw.Text(orden.observaciones ?? 'Sin observaciones.', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 40),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        children: [
                          _buildTotalRow('SUBTOTAL:', orden.montoTotal / 1.18),
                          pw.SizedBox(height: 4),
                          _buildTotalRow('I.G.V. (18%):', orden.montoTotal - (orden.montoTotal / 1.18)),
                          pw.Divider(),
                          _buildTotalRow('TOTAL:', orden.montoTotal, isBold: true),
                          pw.SizedBox(height: 4),
                          _buildTotalRow('A CUENTA:', orden.montoTotal - orden.montoSaldo),
                          pw.Divider(),
                          _buildTotalRow('SALDO:', orden.montoSaldo, isRed: orden.montoSaldo > 0, isBold: orden.montoSaldo > 0),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.BarcodeWidget(barcode: pw.Barcode.code128(), data: orden.numeroOrden, width: 220, height: 45, drawText: true, textStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 20),
                      pw.Text('¡GRACIAS POR SU PREFERENCIA!', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Gestor OCC - Especialistas en Salud Visual', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(bytes: await pdf.save(), filename: "Boleta_${orden.numeroOrden}.pdf");
    } catch (e) {
      rethrow;
    }
  }

  static pw.Widget _buildInfoLabel(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$label ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, double amt, {bool isBold = false, bool isRed = false}) {
    final style = pw.TextStyle(fontSize: 12, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: isRed ? PdfColors.red700 : PdfColors.black);
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
          pw.Flexible(child: pw.Text(valor, style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
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
