import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static pw.Document generarDocumentoPdfTicket(OrdenTrabajo orden, ConfigTienda config) {
    final pdf = pw.Document();
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
          marginRight: 5 * PdfPageFormat.mm
        ),
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
              pw.FittedBox(fit: pw.BoxFit.scaleDown, child: pw.Text('ORDEN DE VENTA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
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
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('MONTURA:', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                        if (orden.precioMontura != null && orden.precioMontura! > 0)
                          pw.Text('S/ ${orden.precioMontura!.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                      ]
                    ),
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
                    if (orden.tipoLunaOd != null && orden.tipoLunaOd!.isNotEmpty)
                      _buildFilaMedidaTicket('OD: ${orden.tipoLunaOd}', orden.precioLunaOd ?? 0),
                    if (orden.tipoLunaOi != null && orden.tipoLunaOi!.isNotEmpty)
                      _buildFilaMedidaTicket('OI: ${orden.tipoLunaOi}', orden.precioLunaOi ?? 0),
                    if ((orden.tipoLunaOd == null || orden.tipoLunaOd!.isEmpty) && (orden.tipoLunaOi == null || orden.tipoLunaOi!.isEmpty))
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

    return pdf;
  }

  static Future<void> imprimirTicket(OrdenTrabajo orden, ConfigTienda config) async {
    try {
      final pdf = generarDocumentoPdfTicket(orden, config);
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
                            pw.Text('ORDEN DE VENTA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900), textAlign: pw.TextAlign.center),
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
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: pw.BoxDecoration(color: PdfColors.blue900, borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))), child: pw.Text('MONTURA', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                                if (orden.precioMontura != null && orden.precioMontura! > 0)
                                  pw.Text('S/ ${orden.precioMontura!.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                              ]
                            ),
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
                            if (orden.tipoLunaOd != null && orden.tipoLunaOd!.isNotEmpty)
                              _buildFilaMedidaA4('O.D: ${orden.tipoLunaOd}', orden.precioLunaOd ?? 0),
                            if (orden.tipoLunaOi != null && orden.tipoLunaOi!.isNotEmpty)
                              _buildFilaMedidaA4('O.I: ${orden.tipoLunaOi}', orden.precioLunaOi ?? 0),
                            
                            if ((orden.tipoLunaOd == null || orden.tipoLunaOd!.isEmpty) && (orden.tipoLunaOi == null || orden.tipoLunaOi!.isEmpty)) ...[
                              pw.Text((orden.tipoLuna != null && orden.tipoLuna!.isNotEmpty) ? orden.tipoLuna!.toUpperCase() : 'SERVICIO ÓPTICO INTEGRAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              if (orden.esLunaCliente == true) pw.Text('(PROPIAS DEL CLIENTE)', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic)),
                            ],
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

      await Printing.sharePdf(bytes: await pdf.save(), filename: "Orden_${orden.numeroOrden}.pdf");
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

  static pw.Widget _buildFilaMedidaTicket(String label, double price) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8)),
          if (price > 0)
            pw.Text('S/ ${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildFilaMedidaA4(String label, double price) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          if (price > 0)
            pw.Text('S/ ${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        ],
      ),
    );
  }

  static Future<String> getPrinterIp(String tienda) async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('printer_ip_$tienda');
    if (savedIp != null && savedIp.isNotEmpty) {
      return savedIp;
    }
    // IPs por defecto para cada tienda
    switch (tienda) {
      case 'C1':
        return '192.168.1.23';
      case 'C2':
        return '192.168.1.24'; // IP tentativa para tienda C2
      case 'C3':
        return '192.168.1.25'; // IP tentativa para tienda C3
      default:
        return '192.168.1.23';
    }
  }

  static Future<void> guardarPrinterIp(String tienda, String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_ip_$tienda', ip);
  }

  static Future<void> _mostrarDialogoCambiarIp(BuildContext context, String tienda, String ipActual, Function(String nuevaIp) onSaved) async {
    final controller = TextEditingController(text: ipActual);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Configurar Ticketera - Sede $tienda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa la dirección IP de la ticketera POS80 para esta sucursal:'),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dirección IP',
                  hintText: 'Ej. 192.168.1.23',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nuevaIp = controller.text.trim();
                if (nuevaIp.isNotEmpty) {
                  onSaved(nuevaIp);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> imprimirDirectoPorRed(BuildContext context, OrdenTrabajo orden, ConfigTienda config) async {
    final tienda = config.tienda.isEmpty ? 'C1' : config.tienda;
    String ip = await getPrinterIp(tienda);
    final int puerto = 9100;

    bool impreso = false;

    // Mostrar un indicador de carga en pantalla
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Generando e imprimiendo diseño...'),
              ],
            ),
          ),
        ),
      ),
    );

    // 1. Generar el PDF usando el mismo diseño
    Uint8List pdfBytes;
    List<PdfRaster> pages = [];
    try {
      final pdf = generarDocumentoPdfTicket(orden, config);
      pdfBytes = await pdf.save();

      // Rasterizar las páginas del PDF. Usamos dpi: 180 para ticketera de 80mm
      await for (final page in Printing.raster(pdfBytes, dpi: 180)) {
        pages.add(page);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Error al procesar diseño visual: $e'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (pages.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('❌ El ticket generado está vacío.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    while (!impreso) {
      Socket? socket;
      try {
        socket = await Socket.connect(ip, puerto, timeout: const Duration(seconds: 5));

        final String esc = '\x1B';
        final String gs = '\x1D';

        // Comandos iniciales de impresora
        socket.add(utf8.encode('$esc@')); // Inicializar
        socket.add(utf8.encode('${esc}a0')); // Alinear a la izquierda (requerido para imágenes raster)

        // Enviar cada página rasterizada como comando ESC/POS raster image
        for (final page in pages) {
          final Uint8List rgbaBytes = page.pixels;
          final int width = page.width;
          final int height = page.height;

          // POS80 usa múltiplos de 8. Calculamos ancho en bytes.
          final int widthBytes = (width + 7) ~/ 8;
          final List<int> imageCmd = [];

          // Comando ESC/POS raster: GS v 0 m xL xH yL yH
          // m=0 (Normal)
          imageCmd.addAll(utf8.encode('${gs}v0\x00'));
          imageCmd.add(widthBytes % 256);
          imageCmd.add(widthBytes ~/ 256);
          imageCmd.add(height % 256);
          imageCmd.add(height ~/ 256);

          socket.add(imageCmd);

          // Convertir RGBA (4 bytes/px) a 1 bit/px
          final List<int> pixelData = List<int>.filled(widthBytes * height, 0);

          for (int y = 0; y < height; y++) {
            for (int byteX = 0; byteX < widthBytes; byteX++) {
              int byteVal = 0;
              for (int bit = 0; bit < 8; bit++) {
                final int pixelX = byteX * 8 + bit;
                if (pixelX < width) {
                  final int rgbaIndex = (y * width + pixelX) * 4;
                  if (rgbaIndex + 3 < rgbaBytes.length) {
                    final int r = rgbaBytes[rgbaIndex];
                    final int g = rgbaBytes[rgbaIndex + 1];
                    final int b = rgbaBytes[rgbaIndex + 2];
                    final int a = rgbaBytes[rgbaIndex + 3];

                    // Si no es transparente (a >= 50) y es un píxel oscuro, lo pintamos de negro
                    if (a >= 50) {
                      final double luminance = 0.299 * r + 0.587 * g + 0.114 * b;
                      if (luminance < 170) { // Umbral de oscuridad (170 es un buen contraste)
                        byteVal |= (1 << (7 - bit));
                      }
                    }
                  }
                }
              }
              pixelData[y * widthBytes + byteX] = byteVal;
            }
          }
          socket.add(pixelData);
        }

        // Avance de papel y comandos finales
        socket.add(utf8.encode('\n\n\n\n'));
        socket.add(utf8.encode('${gs}V\x42\x00')); // Cortar papel
        socket.add(utf8.encode('${esc}p\x00\x19\x96')); // Abrir cajón monedero

        await socket.flush();
        impreso = true;

        Navigator.of(context).pop(); // Cerrar loading dialog

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Ticket impreso con diseño.'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        Navigator.of(context).pop(); // Cerrar loading dialog

        bool reintentar = false;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('⚠️ Error de Impresión'),
              content: Text(
                'No se pudo conectar a la ticketera de la sede $tienda en la dirección IP $ip.\n\n'
                'Asegúrate de que la ticketera esté encendida, conectada a la misma red y con la IP correcta.'
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar diálogo
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Cerrar diálogo
                    await _mostrarDialogoCambiarIp(context, tienda, ip, (nuevaIp) async {
                      ip = nuevaIp;
                      await guardarPrinterIp(tienda, nuevaIp);
                      reintentar = true;
                    });
                  },
                  child: const Text('Cambiar IP'),
                ),
                ElevatedButton(
                  onPressed: () {
                    reintentar = true;
                    Navigator.of(context).pop(); // Cerrar diálogo
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            );
          },
        );

        if (!reintentar) {
          break; // Salir del bucle
        }

        // Si se seleccionó reintentar, volver a abrir el loading dialog en la siguiente iteración
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 15),
                      Text('Conectando a la ticketera...'),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      } finally {
        if (socket != null) {
          await socket.close();
        }
      }
    }
  }
}

